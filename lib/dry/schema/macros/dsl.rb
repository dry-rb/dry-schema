require 'dry/logic/operators'

require 'dry/schema/macros/core'

module Dry
  module Schema
    module Macros
      class DSL < Core
        include Dry::Logic::Operators

        undef :eql?

        option :chain, default: -> { true }

        def value(*predicates, **opts, &block)
          append_macro(Macros::Value) do |macro|
            macro.call(*predicates, **opts, &block)
          end
        end

        def filled(*args, &block)
          append_macro(Macros::Filled) do |macro|
            macro.call(*args, &block)
          end
        end

        def schema(&block)
          append_macro(Macros::Hash) do |macro|
            macro.call(&block)
          end
        end

        def each(*args, &block)
          append_macro(Macros::Each) do |macro|
            macro.value(*args, &block)
          end
        end

        private

        def append_macro(macro_type, &block)
          macro = macro_type.new(schema_dsl: schema_dsl, name: name)

          yield(macro)

          if chain
            trace << macro
            self
          else
            macro
          end
        end
      end
    end
  end
end
