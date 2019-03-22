# frozen_string_literal: true

require 'i18n'
require 'dry/schema/messages/abstract'

module Dry
  module Schema
    # I18n message backend
    #
    # @api public
    class Messages::I18n < Messages::Abstract
      attr_reader :t

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
        end

        messages.prepare

        messages
      end

      # @api private
      def initialize
        super
        @t = I18n.method(:t)
      end

      # @api private
      def prepare
        top_namespace = config.top_namespace

        config.paths.each do |path|
          data = YAML.load_file(path)

          if path.equal?(DEFAULT_PATH) && top_namespace != DEFAULT_TOP_NAMESPACE
            mapped_data = data
              .map { |k, v| [k, { top_namespace => v[DEFAULT_TOP_NAMESPACE] }] }
              .to_h

            store_translations(mapped_data)
          else
            store_translations(data)
          end
        end
      end

      # @api private
      def store_translations(data)
        locales = data.keys.map(&:to_sym)

        ::I18n.available_locales += locales

        locales.each do |locale|
          ::I18n.backend.store_translations(locale, data[locale.to_s])
        end
      end

      # Get a message for the given key and its options
      #
      # @param [Symbol] key
      # @param [Hash] options
      #
      # @return [String]
      #
      # @api public
      def get(key, options = {})
        t.(key, options) if key
      end

      # Check if given key is defined
      #
      # @return [Boolean]
      #
      # @api public
      def key?(key, options)
        ::I18n.exists?(key, options.fetch(:locale, default_locale)) ||
          ::I18n.exists?(key, I18n.default_locale)
      end

      # Merge messages from an additional path
      #
      # @param [String, Array<String>] paths
      #
      # @return [Messages::I18n]
      #
      # @api public
      def merge(paths)
        ::I18n.load_path.concat(Array(paths))
        ::I18n.backend.load_translations
        self
      end

      # @api private
      def default_locale
        I18n.locale || I18n.default_locale || super
      end
    end
  end
end
