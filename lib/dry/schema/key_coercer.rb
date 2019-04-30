# frozen_string_literal: true

require 'dry/core/cache'
require 'dry/equalizer'

module Dry
  module Schema
    # Coerces keys in a hash using provided coercer function
    #
    # @api private
    class KeyCoercer
      extend Dry::Core::Cache
      include ::Dry::Equalizer(:key_map, :coercer)

      TO_SYM = :to_sym.to_proc.freeze

      attr_reader :key_map, :coercer

      # @api private
      def self.new(*args, &coercer)
        fetch_or_store(*args, coercer) { super(*args, &coercer) }
      end

      # @api private
      def self.symbolized(*args)
        new(*args, &TO_SYM)
      end

      # @api private
      def initialize(key_map, &coercer)
        @key_map = key_map.coercible(&coercer)
      end

      # @api private
      def call(source)
        key_map.write(source.to_h)
      end
      alias_method :[], :call
    end
  end
end
