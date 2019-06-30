# frozen_string_literal: true

require 'dry/schema/macros/value'

module Dry
  module Schema
    module Macros
      # Macro used to specify a nested schema
      #
      # @api private
      class Schema < Value
        # @api private
        def call(*args, &block)
          super(*args, &nil) unless args.empty?

          if block
            schema = define(*args, &block)
            trace << schema.to_rule
          end

          self
        end

        private

        # @api private
        def define(*args, &block)
          definition = schema_dsl.new(&block)
          schema = definition.call
          type_schema =
            if array?
              parent_type.of(definition.type_schema)
            elsif redefined_schema?(args)
              parent_type.schema(definition.types)
            else
              definition.type_schema
            end
          final_type = optional? ? type_schema.optional : type_schema

          type(final_type)

          if schema.filter_rules?
            schema_dsl[name].filter { hash?.then(schema(schema.filter_schema)) }
          end

          schema
        end

        # @api private
        def parent_type
          schema_dsl.types[name]
        end

        # @api private
        def optional?
          parent_type.optional?
        end

        # @api private
        def array?
          parent_type.respond_to?(:of)
        end

        # @api private
        def schema?
          parent_type.respond_to?(:schema)
        end

        # @api private
        def redefined_schema?(args)
          schema? && args.first.is_a?(Processor)
        end
      end
    end
  end
end
