require 'dry/core/cache'

module Dry
  module Schema
    class KeyCoercer
      extend Dry::Core::Cache

      TO_SYM = -> v { v.to_sym }.freeze

      attr_reader :key_map, :coercer

      def self.new(*args, &coercer)
        fetch_or_store(*args, coercer) { super(*args, &coercer) }
      end

      def self.symbolized(*args)
        new(*args, &TO_SYM)
      end

      def initialize(key_map, &coercer)
        @key_map = key_map.coercible(&coercer)
      end
      
      def call(source)
        key_map.write(source)
      end
      alias_method :[], :call
    end
  end
end
