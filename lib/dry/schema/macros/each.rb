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
        def value(...)
          append_macro(Macros::Value) do |macro|
            macro.call(...)
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
