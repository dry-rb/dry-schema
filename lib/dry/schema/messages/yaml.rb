# frozen_string_literal: true

require "yaml"
require "pathname"

require "dry/core/equalizer"
require "dry/schema/constants"
require "dry/schema/messages/abstract"

module Dry
  module Schema
    # Plain YAML message backend
    #
    # @api public
    class Messages::YAML < Messages::Abstract
      LOCALE_TOKEN = "%<locale>s"
      TOKEN_REGEXP = /%{(\w*)}/.freeze
      EMPTY_CONTEXT = Object.new.tap { |ctx|
        def ctx.context
          binding
        end
      }.freeze.context

      include Dry::Equalizer(:data)

      # Loaded localized message templates
      #
      # @return [Hash]
      attr_reader :data

      # Translation function
      #
      # @return [Proc]
      attr_reader :t

      # @api private
      def self.build(options = EMPTY_HASH)
        super do |config|
          config.default_locale = :en unless config.default_locale

          config.root = "%<locale>s.#{config.root}"

          config.rule_lookup_paths = config.rule_lookup_paths.map { |path|
            "%<locale>s.#{path}"
          }
        end
      end

      # @api private
      def self.flat_hash(hash, path = [], keys = {})
        hash.each do |key, value|
          flat_hash(value, [*path, key], keys) if value.is_a?(Hash)

          if value.is_a?(String) && hash["text"] != value
            keys[[*path, key].join(DOT)] = {
              text: value,
              meta: EMPTY_HASH
            }
          elsif value.is_a?(Hash) && value["text"].is_a?(String)
            keys[[*path, key].join(DOT)] = {
              text: value["text"],
              meta: value.dup.delete_if { |k| k == "text" }.map { |k, v| [k.to_sym, v] }.to_h
            }
          end
        end
        keys
      end

      # @api private
      def self.cache
        @cache ||= Concurrent::Map.new { |h, k| h[k] = Concurrent::Map.new }
      end

      # @api private
      def self.source_cache
        @source_cache ||= Concurrent::Map.new
      end

      # @api private
      def initialize(data: EMPTY_HASH, config: nil)
        super()
        @data = data
        @config = config if config
        @t = proc { |key, locale: default_locale| get("%<locale>s.#{key}", locale: locale) }
      end

      # Get an array of looked up paths
      #
      # @param [Symbol] predicate
      # @param [Hash] options
      #
      # @return [String]
      #
      # @api public
      def looked_up_paths(predicate, options)
        super.map { |path| path % {locale: options[:locale] || default_locale} }
      end

      # Get a message for the given key and its options
      #
      # @param [Symbol] key
      # @param [Hash] options
      #
      # @return [String]
      #
      # @api public
      def get(key, options = EMPTY_HASH)
        data[evaluated_key(key, options)]
      end

      # Check if given key is defined
      #
      # @return [Boolean]
      #
      # @api public
      def key?(key, options = EMPTY_HASH)
        data.key?(evaluated_key(key, options))
      end

      # Merge messages from an additional path
      #
      # @param [String] overrides
      #
      # @return [Messages::I18n]
      #
      # @api public
      def merge(overrides)
        if overrides.is_a?(Hash)
          self.class.new(
            data: data.merge(self.class.flat_hash(overrides)),
            config: config
          )
        else
          self.class.new(
            data: Array(overrides).reduce(data) { |a, e| a.merge(load_translations(e)) },
            config: config
          )
        end
      end

      # @api private
      def prepare
        @data = config.load_paths.map { |path| load_translations(path) }.reduce({}, :merge)
        self
      end

      # @api private
      def interpolatable_data(key, options, **data)
        tokens = evaluation_context(key, options).fetch(:tokens)
        data.select { |k,| tokens.include?(k) }
      end

      # @api private
      def interpolate(key, options, **data)
        evaluator = evaluation_context(key, options).fetch(:evaluator)
        data.empty? ? evaluator.() : evaluator.(**data)
      end

      private

      # @api private
      def evaluation_context(key, options)
        cache.fetch_or_store(get(key, options).fetch(:text)) do |input|
          tokens = input.scan(TOKEN_REGEXP).flatten(1).map(&:to_sym).to_set
          text = input.gsub("%", "#")

          # rubocop:disable Security/Eval
          evaluator = eval(<<~RUBY, EMPTY_CONTEXT, __FILE__, __LINE__ + 1)
            -> (#{tokens.map { |token| "#{token}:" }.join(", ")}) { "#{text}" }
          RUBY
          # rubocop:enable Security/Eval

          {
            tokens: tokens,
            evaluator: evaluator
          }
        end
      end

      # @api private
      def cache
        @cache ||= self.class.cache[self]
      end

      # @api private
      def load_translations(path)
        data = self.class.source_cache.fetch_or_store(path) do
          self.class.flat_hash(YAML.load_file(path)).freeze
        end

        return data unless custom_top_namespace?(path)

        data.map { |k, v| [k.gsub(DEFAULT_MESSAGES_ROOT, config.top_namespace), v] }.to_h
      end

      # @api private
      def evaluated_key(key, options)
        return key unless key.include?(LOCALE_TOKEN)

        key % {locale: options[:locale] || default_locale}
      end
    end
  end
end
