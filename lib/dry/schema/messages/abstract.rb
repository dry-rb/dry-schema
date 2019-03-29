# frozen_string_literal: true

require 'set'
require 'concurrent/map'
require 'dry/equalizer'
require 'dry/configurable'

require 'dry/schema/constants'
require 'dry/schema/messages/template'

module Dry
  module Schema
    module Messages
      # Abstract class for message backends
      #
      # @api public
      class Abstract
        include Dry::Configurable
        include Dry::Equalizer(:config)

        setting :load_paths, Set[DEFAULT_MESSAGES_PATH]
        setting :top_namespace, DEFAULT_MESSAGES_ROOT
        setting :root, 'errors'
        setting :lookup_options, %i[root predicate path val_type arg_type].freeze

        setting :lookup_paths, [
          '%<root>s.rules.%<path>s.%<predicate>s.arg.%<arg_type>s',
          '%<root>s.rules.%<path>s.%<predicate>s',
          '%<root>s.%<predicate>s.%<message_type>s',
          '%<root>s.%<predicate>s.value.%<path>s.arg.%<arg_type>s',
          '%<root>s.%<predicate>s.value.%<path>s',
          '%<root>s.%<predicate>s.value.%<val_type>s.arg.%<arg_type>s',
          '%<root>s.%<predicate>s.value.%<val_type>s',
          '%<root>s.%<predicate>s.arg.%<arg_type>s',
          '%<root>s.%<predicate>s'
        ].freeze

        setting :rule_lookup_paths, ['rules.%<name>s'].freeze

        setting :arg_types, Hash.new { |*| 'default' }.update(
          Range => 'range'
        )

        setting :val_types, Hash.new { |*| 'default' }.update(
          Range => 'range',
          String => 'string'
        )

        # @api private
        def self.cache
          @cache ||= Concurrent::Map.new { |h, k| h[k] = Concurrent::Map.new }
        end

        # @api private
        def self.build(options = EMPTY_HASH)
          messages = new

          messages.configure do |config|
            options.each do |key, value|
              config.public_send(:"#{key}=", value)
            end

            config.root = "#{config.top_namespace}.#{config.root}"

            config.rule_lookup_paths = config.rule_lookup_paths.map { |path|
              "#{config.top_namespace}.#{path}"
            }

            yield(config) if block_given?
          end

          messages.prepare
        end

        # @api private
        def hash
          @hash ||= config.hash
        end

        # @api private
        def translate(key, locale: default_locale)
          t["#{config.top_namespace}.#{key}", locale: locale]
        end

        # @api private
        def rule(name, options = {})
          tokens = { name: name, locale: options.fetch(:locale, default_locale) }
          path = rule_lookup_paths(tokens).detect { |key| key?(key, options) }

          get(path, options) if path
        end

        # Retrieve a message template
        #
        # @return [Template]
        #
        # @api public
        def call(*args)
          cache.fetch_or_store(args.hash) do
            path, opts = lookup(*args)
            Template[get(path, opts)] if path
          end
        end
        alias_method :[], :call

        # Try to find a message for the given predicate and its options
        #
        # @api private
        def lookup(predicate, options)
          tokens = options.merge(
            predicate: predicate,
            root: options[:not] ? "#{root}.not" : root,
            arg_type: config.arg_types[options[:arg_type]],
            val_type: config.val_types[options[:val_type]],
            message_type: options[:message_type] || :failure
          )

          opts = options.reject { |k, _| config.lookup_options.include?(k) }

          path = lookup_paths(tokens).detect { |key| key?(key, opts) }

          [path, opts]
        end

        # @api private
        def lookup_paths(tokens)
          config.lookup_paths.map { |path| path % tokens }
        end

        # @api private
        def rule_lookup_paths(tokens)
          config.rule_lookup_paths.map { |key| key % tokens }
        end

        # Return a new message backend that will look for messages under provided namespace
        #
        # @param [Symbol,String] namespace
        #
        # @api public
        def namespaced(namespace)
          Dry::Schema::Messages::Namespaced.new(namespace, self)
        end

        # Return root path to messages file
        #
        # @return [Pathname]
        #
        # @api public
        def root
          config.root
        end

        # @api private
        def cache
          @cache ||= self.class.cache[self]
        end

        # @api private
        def default_locale
          :en
        end

        private

        # @api private
        def custom_top_namespace?(path)
          path.to_s == DEFAULT_MESSAGES_PATH.to_s && config.top_namespace != DEFAULT_MESSAGES_ROOT
        end
      end
    end
  end
end
