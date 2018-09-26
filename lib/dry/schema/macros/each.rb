require 'dry/schema/macros/core'

module Dry
  module Schema
    module Macros
      class Each < Core
        def to_ast
          [:each, trace.to_ast]
        end
      end
    end
  end
end
