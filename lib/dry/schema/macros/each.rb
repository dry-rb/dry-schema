require 'dry/schema/macros/dsl'

module Dry
  module Schema
    module Macros
      class Each < DSL
        def to_ast(*)
          [:each, trace.to_ast]
        end
        alias_method :ast, :to_ast
      end
    end
  end
end
