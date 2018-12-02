require 'dry/schema/macros/dsl'
require 'dry/schema/constants'

module Dry
  module Schema
    module Macros
      class Key < DSL
        option :input_schema, optional: true, default: proc { schema_dsl&.new }

        def filter(*args, &block)
          input_schema.optional(name).value(*args, &block)
          self
        end

        def value(*args, **opts, &block)
          extract_type_spec(*args) do |*predicates|
            super(*predicates, **opts, &block)
          end
        end

        def filled(*args, **opts, &block)
          extract_type_spec(*args) do |*predicates|
            super(*predicates, **opts, &block)
          end
        end

        def maybe(*args, **opts, &block)
          extract_type_spec(*args) do |*predicates|
            append_macro(Macros::Maybe) do |macro|
              macro.call(*predicates, **opts, &block)
            end
          end
        end

        def type(args)
          schema_dsl.set_type(name, args)
          self
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

        private

        def extract_type_spec(*args)
          type_spec = args[0].is_a?(Symbol) && !args[0].to_s.end_with?(QUESTION_MARK) && args[0]
          predicates = type_spec ? args[1, -1] : args
          type(type_spec) if type_spec
          yield(*predicates)
        end
      end
    end
  end
end
