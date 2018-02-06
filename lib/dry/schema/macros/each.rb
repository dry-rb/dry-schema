require 'dry/schema/constants'
require 'dry/schema/macros/core'

module Dry
  module Schema
    module Macros
      class Each < Core
        def to_ast
          [:each, trace.to_rule.to_ast]
        end

        def to_rule
          compiler.visit(to_ast)
        end
      end
    end
  end
end
