# frozen_string_literal: true

require 'dry/schema/macros/schema'

module Dry
  module Schema
    module Macros
      # Macro used to specify a nested schema
      #
      # @api public
      class Hash < Schema
        # @api private
        def call(*args, &block)
          trace << hash?

          super(*args) unless args.empty?

          if block
            definition = schema_dsl.new(&block)

            parent_type = schema_dsl.types[name]
            definition_schema = definition.type_schema

            schema_type =
              if parent_type.respond_to?(:of)
                parent_type.of(definition_schema)
              else
                definition_schema
              end

            final_type =
              if parent_type.optional?
                schema_type.optional
              else
                schema_type
              end

            schema_dsl.set_type(name, final_type)

            trace << definition.to_rule
          end

          self
        end
      end
    end
  end
end
