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

          if value.is_a?(String) && hash['text'] != value
            keys[[*path, key].join(DOT)] = {
              text: value,
              meta: EMPTY_HASH
            }
          elsif value.is_a?(Hash) && value['text'].is_a?(String)
            keys[[*path, key].join(DOT)] = {
              text: value['text'],
              meta: value.dup.delete_if { |k| k == 'text' }.map { |k, v| [k.to_sym, v] }.to_h
            }
          end
        end
        keys
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
