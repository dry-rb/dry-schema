# frozen_string_literal: true

require 'dry/schema/macros/dsl'

module Dry
  module Schema
    module Macros
      # Macro used to specify predicates for each element of an array
      #
      # @api private
      class Array < DSL
        # @api private
        def value(*args, **opts, &block)
          type(:array)

          extract_type_spec(*args, set_type: false) do |*predicates, type_spec:|
            type(schema_dsl.array[type_spec]) if type_spec

            is_hash_block = type_spec.equal?(:hash)

            if predicates.any? || opts.any? || !is_hash_block
              super(*predicates, type_spec: type_spec, **opts, &(is_hash_block ? nil : block))
            end

            hash(&block) if is_hash_block
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
