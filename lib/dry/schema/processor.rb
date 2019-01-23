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
        Result.new(input, message_compiler: message_compiler) do |result|
          steps.each do |step|
            output = step.(result)
            result.set(output) if output.is_a?(::Hash)
          end
        end
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
        # TODO: make this more explicit through class types
        @__definition__ ||= steps.last
      end
      alias_method :to_rule, :definition
    end
  end
end
