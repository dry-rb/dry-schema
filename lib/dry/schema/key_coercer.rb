require 'dry/schema/constants'

module Dry
  module Schema
    class KeyCoercer
      attr_reader :key_map, :coercer
      
      def initialize(key_map, &coercer)
        @key_map = key_map.coercible(&coercer)
        @coercer = coercer
      end
      
      def call(source)
        key_map.write(source)
      end
      alias_method :[], :call
    end
  end
end
