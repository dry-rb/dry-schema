require 'dry/schema/macros/core'

module Dry
  module Schema
    module Macros
      class Key < Core
        option :name

        def to_rule
          if trace.empty?
            super
          else
            [super, trace.to_rule(name)].reduce(operation)
          end
        end

        def to_ast
          [:predicate, [:key?, [[:name, name], [:input, Undefined]]]]
        end
      end
    end
  end
end
