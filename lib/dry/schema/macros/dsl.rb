require 'dry/schema/macros/core'

module Dry
  module Schema
    module Macros
      class DSL < Core
        undef :eql?

        def value(*predicates, **opts, &block)
          macro = Macros::Value.new(schema_dsl: schema_dsl, name: name)
          macro.call(*predicates, **opts, &block)
          trace << macro
          self
        end

        def filled(*args, &block)
          macro = Macros::Filled.new(schema_dsl: schema_dsl, name: name)
          macro.call(*args, &block)
          trace << macro
          self
        end

        def schema(&block)
          macro = Macros::Hash.new(schema_dsl: schema_dsl, name: name)
          macro.call(&block)
          trace << macro
          self
        end

        def each(*args, &block)
          macro = Macros::Each.new(schema_dsl: schema_dsl, name: name)
          macro.value(*args, &block)
          trace << macro
          self
        end

        private

        def method_missing(meth, *args, &block)
          trace.__send__(meth, *args, &block)
        end
      end
    end
  end
end
