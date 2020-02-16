# frozen_string_literal: true

require 'i18n'
require 'dry/schema/messages/abstract'

module Dry
  module Schema
    # I18n message backend
    #
    # @api public
    class Messages::I18n < Messages::Abstract
      # Translation function
      #
      # @return [Method]
      attr_reader :t

      # @api private
      def initialize
        super
        @t = I18n.method(:t)
      end

      # Get a message for the given key and its options
      #
      # @param [Symbol] key
      # @param [Hash] options
      #
      # @return [String]
      #
      # @api public
      def get(key, data, options = EMPTY_HASH)
        return unless key

        opts = { **data, locale: options.fetch(:locale, default_locale) }

        text_key = "#{key}.text"

        if key?(text_key, opts)
          resolved_key = text_key
          meta = extract_meta(key, opts)
        else
          resolved_key = key
          meta = EMPTY_HASH
        end

        {
          text: t.(resolved_key, **opts),
          meta: meta
        }
      end

      # Check if given key is defined
      #
      # @return [Boolean]
      #
      # @api public
      def key?(key, options)
        I18n.exists?(key, options.fetch(:locale, default_locale)) ||
          I18n.exists?(key, I18n.default_locale)
      end

      # Merge messages from an additional path
      #
      # @param [String, Array<String>] paths
      #
      # @return [Messages::I18n]
      #
      # @api public
      def merge(paths)
        prepare(paths)
      end

      # @api private
      def default_locale
        super || I18n.locale || I18n.default_locale
      end

      # @api private
      def prepare(paths = config.load_paths)
        paths.each do |path|
          data = YAML.load_file(path)

          if custom_top_namespace?(path)
            top_namespace = config.top_namespace

            mapped_data = data
              .map { |k, v| [k, { top_namespace => v[DEFAULT_MESSAGES_ROOT] }] }
              .to_h

            store_translations(mapped_data)
          else
            store_translations(data)
          end
        end

        self
      end

      private

      # @api private
      def store_translations(data)
        locales = data.keys.map(&:to_sym)

        I18n.available_locales |= locales

        locales.each do |locale|
          I18n.backend.store_translations(locale, data[locale.to_s])
        end
      end

      def extract_meta(parent_key, options)
        t.(parent_key, **options).each_with_object({}) do |(key, _), meta|
          unless key.to_sym == :text
            meta_key = "#{parent_key}.#{key}"
            meta[key] = t.(meta_key, **options) if key?(meta_key, options)
          end
        end
      end
    end
  end
end
