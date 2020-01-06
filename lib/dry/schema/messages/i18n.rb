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
      def get(key, options = EMPTY_HASH)
        return unless key

        opts = { locale: options.fetch(:locale, default_locale) }

        translation = t.(key, **opts)
        text_key = "#{key}.text"

        if !translation.is_a?(Hash) || !key?(text_key, opts)
          return {
            text: translation,
            meta: EMPTY_HASH
          }
        end

        {
          text: t.(text_key, **opts),
          meta: extract_meta(key, translation, opts)
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

      # @api private
      def cache_key(predicate, options)
        if options[:locale]
          super
        else
          [*super, I18n.locale]
        end
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

      def extract_meta(parent_key, translation, options)
        translation.keys.each_with_object({}) do |k, meta|
          meta_key = "#{parent_key}.#{k}"
          meta[k] = t.(meta_key, **options) if k != :text && key?(meta_key, options)
        end
      end
    end
  end
end
