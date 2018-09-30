require 'dry/schema/macros/core'
require 'dry/schema/macros/value'
require 'dry/schema/macros/filled'
require 'dry/schema/macros/each'
require 'dry/schema/macros/maybe'
require 'dry/schema/macros/hash'

module Dry
  module Schema
    module Macros
      class Key < Core
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
