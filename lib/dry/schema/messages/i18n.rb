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

      configure do |config|
        config.root = 'dry_schema.errors'
        config.rule_lookup_paths = config.rule_lookup_paths.map { |path| "dry_schema.#{path}" }
      end

      # @api private
      def self.build(paths = config.paths)
        set_load_paths(paths)
        new
      end

      # @api private
      def self.set_load_paths(paths)
        ::I18n.load_path.concat(paths)
      end

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
      # @param [String] path
      #
      # @return [Messages::I18n]
      #
      # @api public
      def merge(path)
        ::I18n.load_path << path
        self
      end

      # @api private
      def default_locale
        I18n.locale || I18n.default_locale || super
      end
    end
  end
end
