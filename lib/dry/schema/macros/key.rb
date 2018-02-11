require 'dry/schema/macros/core'

module Dry
  module Schema
    module Macros
      class Key < Core
        def to_ast
          [:predicate, [:key?, [[:name, name], [:input, Undefined]]]]
        end
      end
    end
  end
end
