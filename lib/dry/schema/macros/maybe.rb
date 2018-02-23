require 'dry/schema/macros/key'

module Dry
  module Schema
    module Macros
      class Maybe < Core
        def to_ast
          [:implication,
           [
             [:not, [:predicate, [:none?, [[:input, Undefined]]]]],
             *trace.to_ast
           ]
          ]
        end
      end
    end
  end
end
