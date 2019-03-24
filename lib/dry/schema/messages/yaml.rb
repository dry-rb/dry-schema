# frozen_string_literal: true

require 'yaml'
require 'pathname'

require 'dry/equalizer'
require 'dry/schema/constants'
require 'dry/schema/messages/abstract'

module Dry
  module Schema
    # Plain YAML message backend
    #
    # @api public
    class Messages::YAML < Messages::Abstract
      LOCALE_TOKEN = '%<locale>s'

      include Dry::Equalizer(:data)

      attr_reader :data, :t

      # @api private
      def self.build(options = EMPTY_HASH)
        messages = new

        messages.configure do |config|
          options.each do |key, value|
            config.public_send(:"#{key}=", value)
          end

          config.root = "%<locale>s.#{config.top_namespace}.#{config.root}"

          config.rule_lookup_paths = config.rule_lookup_paths.map { |path|
            "%<locale>s.#{config.top_namespace}.#{path}"
          }
        end

        messages.prepare

        messages
      end

      # @api private
      def self.flat_hash(hash, acc = [], result = {})
        return result.update(acc.join(DOT) => hash) unless hash.is_a?(Hash)

        hash.each { |k, v| flat_hash(v, acc + [k], result) }
        result
      end

      # @api private
      def initialize(data: EMPTY_HASH, config: nil)
        super()
        @data = data
        @config = config if config
        @t = proc { |key, locale: default_locale| get("%<locale>s.#{key}", locale: locale) }
      end

      # @api private
      def prepare
        @data = config.paths.map { |path| load_translations(path) }.reduce(:merge)
      end

      # @api private
      def load_translations(path)
        data = self.class.flat_hash(YAML.load_file(path))

        unless path.equal?(DEFAULT_PATH) && config.top_namespace != DEFAULT_TOP_NAMESPACE
          return data
        end

        data.map { |k, v| [k.gsub(DEFAULT_TOP_NAMESPACE, config.top_namespace), v] }.to_h
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
      # @param [String] path
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

      private

      # @api private
      def evaluated_key(key, options)
        return key unless key.include?(LOCALE_TOKEN)

        key % { locale: options[:locale] || default_locale }
      end
    end
  end
end
