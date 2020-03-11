# frozen_string_literal: true

require "dry/types/type"
require "dry/schema/macros/dsl"

module Dry
  module Schema
    module Macros
      # Macro used to specify predicates for each element of an array
      #
      # @api private
      class Each < DSL
        # @api private
        def value(*args, **opts)
          extract_type_spec(*args, set_type: false) do |*predicates, type_spec:, type_rule:|
            if type_spec && !type_spec.is_a?(Dry::Types::Type)
              type(schema_dsl.array[type_spec])
            end

            super(*predicates, type_spec: type_spec, type_rule: type_rule, **opts)
          end
        end

        # @api private
        def to_ast(*)
          [:each, trace.to_ast]
        end
        alias_method :ast, :to_ast
      end
    end
  end
end
