# frozen_string_literal: true

require "dry/schema/macros/dsl"

module Dry
  module Schema
    module Macros
      # Macro used to specify predicates for each element of an array
      #
      # @api public
      class Array < DSL
        # @api private
        def value(*args, &block)
          schema_dsl.set_type(name, :array)
          super
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
