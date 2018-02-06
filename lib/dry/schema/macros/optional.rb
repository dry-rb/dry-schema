require 'dry/schema/constants'
require 'dry/schema/macros/core'

module Dry
  module Schema
    module Macros
      class Optional < Core
        def to_ast
          [:predicate, [:key?, [[:name, name], [:input, Undefined]]]]
        end

        def operation
          :then
        end
      end
    end
  end
end
