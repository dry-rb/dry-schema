require 'dry/schema/macros/dsl'

module Dry
  module Schema
    module Macros
      class Key < DSL
        def maybe(*args, **opts, &block)
          macro = Maybe.new(schema_dsl: schema_dsl, name: name)
          macro.call(*args, **opts, &block)
          trace << macro
          self
        end

        def to_rule
          if trace.nodes.empty?
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
