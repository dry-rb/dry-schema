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
          super(*args) unless args.empty?

          if block
            schema = define(&block)
            trace << schema.to_rule
          end

          self
        end

        private

        # @api private
        def define(&block)
          definition = schema_dsl.new(&block)
          schema = definition.call

          type_schema = array? ? parent_type.of(definition.type_schema) : definition.type_schema
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
      end
    end
  end
end
