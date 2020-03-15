# frozen_string_literal: true

require "dry/schema/macros/dsl"

module Dry
  module Schema
    module Macros
      # Macro used to specify predicates for each element of an array
      #
      # @api private
      class Array < DSL
        # @api private
        def value(*predicates, type_spec:, type_rule:, **opts, &block)
          type(:array)

          type(schema_dsl.array[type_spec]) if type_spec

          is_hash_block = type_spec.equal?(:hash)

          if predicates.any? || opts.any? || !is_hash_block
            super(
              *predicates, type_spec: type_spec, type_rule: type_rule, **opts,
              &(is_hash_block ? nil : block)
            )
          end

          is_op = predicates.size.equal?(2) && predicates[1].is_a?(Logic::Operations::Abstract)

          if is_hash_block && !is_op
            hash(&block)
          elsif is_op
            hash = Value.new(schema_dsl: schema_dsl.new, name: name).hash(args[1])

            trace.captures.concat(hash.trace.captures)

            type(schema_dsl.types[name].of(hash.schema_dsl.types[name]))
          end

          self
        end

        # @api private
        def to_ast(*)
          [:and, [trace.array?.to_ast, [:each, trace.to_ast]]]
        end
        alias_method :ast, :to_ast
      end
    end
  end
end
