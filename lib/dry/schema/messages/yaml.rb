require 'yaml'
require 'pathname'

require 'dry/equalizer'
require 'dry/schema/messages/abstract'

module Dry
  module Schema
    # Plain YAML message backend
    #
    # @api public
    class Messages::YAML < Messages::Abstract
      include Dry::Equalizer(:data)

      attr_reader :data

      # @api private
      configure do |config|
        config.root = '%{locale}.errors'.freeze
      end

      # @api private
      def self.load(paths = config.paths)
        new(paths.map { |path| load_file(path) }.reduce(:merge))
      end

      # @api private
      def self.load_file(path)
        flat_hash(YAML.load_file(path))
      end

      # @api private
      def self.flat_hash(h, f = [], g = {})
        return g.update(f.join('.'.freeze) => h) unless h.is_a? Hash
        h.each { |k, r| flat_hash(r, f + [k], g) }
        g
      end

      # @api private
      def initialize(data)
        super()
        @data = data
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
        data[key % { locale: options.fetch(:locale, default_locale) }]
      end

      # Check if given key is defined
      #
      # @return [Boolean]
      #
      # @api public
      def key?(key, options = {})
        data.key?(key % { locale: options.fetch(:locale, default_locale) })
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
          self.class.new(data.merge(self.class.flat_hash(overrides)))
        else
          self.class.new(data.merge(Messages::YAML.load_file(overrides)))
        end
      end
    end
  end
end
