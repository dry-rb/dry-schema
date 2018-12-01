require 'dry/schema/macros/dsl'
require 'dry/schema/constants'

module Dry
  module Schema
    module Macros
      class Key < DSL
        option :input_schema, optional: true, default: proc { schema_dsl&.new }

        def input(*args, &block)
          input_schema.required(name).value(*args, &block)
          self
        end

        def type(*args)
          schema_dsl.set_type(name, args)
          self
        end

        def maybe(*args, **opts, &block)
          append_macro(Macros::Maybe) do |macro|
            macro.call(*args, **opts, &block)
          end
        end

        def to_rule
          if trace.captures.empty?
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
