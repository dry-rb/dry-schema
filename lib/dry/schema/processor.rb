require 'dry/configurable'
require 'dry/initializer'

require 'dry/schema/type_registry'
require 'dry/schema/rule_applier'
require 'dry/schema/key_coercer'
require 'dry/schema/value_coercer'

module Dry
  module Schema
    class Processor
      extend Dry::Initializer
      extend Dry::Configurable

      setting :key_map_type
      setting :type_registry, TypeRegistry.new

      param :steps, default: -> { EMPTY_ARRAY.dup }

      def self.define(&block)
        @__definition__ ||= DSL.new(
          processor_type: self, parent: superclass.definition, **config, &block
        )
        self
      end

      def self.definition
        @__definition__
      end

      def self.new(&block)
        if block
          super.tap(&block)
        elsif definition
          definition.call
        else
          raise ArgumentError, 'Cannot create a schema without a definition'
        end
      end

      def <<(step)
        steps << step
        self
      end

      def call(input)
        Result.new(input, message_compiler: message_compiler) do |result|
          steps.each do |step|
            output = step.(result)
            result.replace(output) if output.is_a?(::Hash)
          end
        end
      end

      def to_ast
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
