require 'dry/initializer'

require 'dry/schema/definition'
require 'dry/schema/key_coercer'
require 'dry/schema/value_coercer'

module Dry
  module Schema
    class Processor
      extend Dry::Initializer

      param :steps, default: -> { EMPTY_ARRAY.dup }

      def self.new(&block)
        super.tap(&block)
      end

      def <<(step)
        steps << step
        self
      end

      def call(input)
        steps.reduce(input) { |a, e| e.(a) }
      end

      def to_ast
        definition.to_ast
      end

      # required by Dry::Logic::Rule interface
      def ast(input)
        definition.to_ast
      end

      def key_map
        @__key_map__ ||= steps.detect { |s| s.is_a?(KeyCoercer) }.key_map
      end

      def type_schema
        @__type_schema__ ||= steps.detect { |s| s.is_a?(ValueCoercer) }.type_schema
      end

      def message_compiler
        definition.message_compiler
      end

      def rules
        definition.rules
      end

      def definition
        @__definition__ ||= steps.detect { |s| s.is_a?(Definition) }
      end
      alias_method :to_rule, :definition
    end
  end
end
