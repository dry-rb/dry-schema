require 'dry/schema/constants'
require 'dry/schema/macros/core'
require 'dry/schema/macros/each'

module Dry
  module Schema
    module Macros
      class Required < Core
        def each(*args)
          macro = args.each_with_object(Each.new(nil)) { |a, e| e.public_send(*a) }
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
