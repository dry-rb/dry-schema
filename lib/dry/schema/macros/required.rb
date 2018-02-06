require 'dry/schema/constants'
require 'dry/schema/macros/core'
require 'dry/schema/macros/each'

module Dry
  module Schema
    module Macros
      class Required < Core
        def each(*args, &block)
          macro = Each.new(nil)
          macro.value(*args, &block)
          trace << macro
          self
        end

        def to_ast
          [:predicate, [:key?, [[:name, name], [:input, Undefined]]]]
        end

        def operation
          :and
        end
      end
    end
  end
end
