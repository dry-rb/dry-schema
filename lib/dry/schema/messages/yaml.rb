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
        super do |config|
          config.root = "%<locale>s.#{config.root}"

          config.rule_lookup_paths = config.rule_lookup_paths.map { |path|
            "%<locale>s.#{path}"
          }
        end
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

      # @api private
      def prepare
        @data = config.load_paths.map { |path| load_translations(path) }.reduce(:merge)
        self
      end

      private

      # @api private
      def load_translations(path)
        data = self.class.flat_hash(YAML.load_file(path))

        return data unless custom_top_namespace?(path)

        data.map { |k, v| [k.gsub(DEFAULT_MESSAGES_ROOT, config.top_namespace), v] }.to_h
      end

      # @api private
      def evaluated_key(key, options)
        return key unless key.include?(LOCALE_TOKEN)

        key % { locale: options[:locale] || default_locale }
      end
    end
  end
end
