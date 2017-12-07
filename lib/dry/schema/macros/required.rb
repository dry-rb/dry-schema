require 'dry/schema/constants'
require 'dry/schema/macros/core'

module Dry
  module Schema
    module Macros
      class Required < Core
        def filled(*args, **opts)
          value(:filled?, *args, **opts)
        end

        def to_ast
          [:predicate, [:key?, [[:name, name], [:input, Undefined]]]]
        end
      end
    end
  end
end
