# frozen_string_literal: true

require "dry/schema/macros/value"

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

          if args.size.equal?(1) && (op = args.first).is_a?(Dry::Logic::Operations::Abstract)
            process_operation(op)
          end

          if block
            schema = define(*args, &block)
            import_steps(schema)
            trace << schema.to_rule
          end

          self
        end

        private

        # @api private
        def process_operation(op)
          schemas = op.rules.select { |rule| rule.is_a?(Processor) }

          hash_schema = hash_type.schema(
            schemas.map(&:schema_dsl).map(&:types).reduce(:merge)
          )

          type(hash_schema)
        end

        # @api private
        def hash_type
          schema_dsl.resolve_type(:hash)
        end

        # @api private
        def define(*args, &block)
          definition = schema_dsl.new(path: schema_dsl.path, &block)
          schema = definition.call
          type_schema =
            if array_type?(parent_type)
              build_array_type(parent_type, definition.type_schema)
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
