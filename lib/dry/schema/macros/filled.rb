# frozen_string_literal: true

require "dry/schema/macros/value"

module Dry
  module Schema
    module Macros
      # Macro used to prepend `:filled?` predicate
      #
      # @api private
      class Filled < Value
        # @api private
        def call(*predicates, **opts, &block)
          ensure_valid_predicates(predicates)

          if opts[:type_spec] && !filter_empty_string?
            value(predicates[0], :filled?, *predicates[1..predicates.size - 1], **opts, &block)
          elsif opts[:type_rule]
            value(:filled?).value(*predicates, **opts, &block)
          else
            value(:filled?, *predicates, **opts, &block)
          end
        end

        # @api private
        def ensure_valid_predicates(predicates)
          if predicates.include?(:empty?)
            raise ::Dry::Schema::InvalidSchemaError, "Using filled with empty? predicate is invalid"
          end

          if predicates.include?(:filled?)
            raise ::Dry::Schema::InvalidSchemaError, "Using filled with filled? is redundant"
          end
        end

        # @api private
        def filter_empty_string?
          !expected_primitives.include?(NilClass) && processor_config.filter_empty_string
        end

        # @api private
        def processor_config
          schema_dsl.processor_type.config
        end

        # @api private
        def expected_primitives
          primitive_inferrer[schema_type]
        end

        # @api private
        def schema_type
          schema_dsl.types[name]
        end
      end
    end
  end
end
