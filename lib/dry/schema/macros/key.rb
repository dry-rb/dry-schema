require 'dry/schema/macros/core'

module Dry
  module Schema
    module Macros
      class Key < Core
        option :name

        def to_rule
          [super, trace.to_rule(name)].compact.reduce(operation)
        end

        def to_ast
          [:predicate, [:key?, [[:name, name], [:input, Undefined]]]]
        end
      end
    end
  end
end
