require 'dry/initializer'

require 'dry/schema/definition'
require 'dry/schema/compiler'
require 'dry/schema/trace'

module Dry
  # <TODO>: figure out what to do with these helpers
  class Types::Sum
    def maybe?
      left.primitive == NilClass
    end

    def hash?
      right.primitive == Hash
    end

    def array?
      right.primitive == Array
    end
  end

  class Types::Definition
    def maybe?
      false
    end

    def hash?
      primitive == Hash
    end

    def array?
      primitive == Array
    end
  end
  # </TODO>

  module Schema
    module Macros
      class Core
        extend Dry::Initializer

        undef :eql?

        option :name, default: proc { nil }, optional: true

        option :compiler, default: proc { Compiler.new }

        option :trace, default: proc { Trace.new }

        option :schema_dsl, optional: true

        option :block, optional: true

        def value(*predicates, **opts, &block)
          macro = Value.new(schema_dsl: schema_dsl, name: name)
          macro.call(*predicates, **opts, &block)
          trace << macro
          self
        end

        def filled(*args, &block)
          macro = Filled.new(schema_dsl: schema_dsl, name: name)
          macro.call(*args, &block)
          trace << macro
          self
        end

        def schema(&block)
          definition = schema_dsl.new(&block)

          parent_type = schema_dsl.types[name]
          definition_schema = definition.type_schema

          schema_type = parent_type.array? ? parent_type.of(definition_schema).safe : definition_schema
          schema_dsl.types[name] = parent_type.maybe? ? schema_type.optional : schema_type

          trace << ::Dry::Schema::Definition.new(definition.call)

          self
        end

        def each(*args, &block)
          macro = Each.new(schema_dsl: schema_dsl, name: name)
          macro.value(*args, &block)
          trace << macro
          self
        end

        def to_rule
          compiler.visit(to_ast)
        end

        def to_ast
          raise NotImplementedError
        end

        def operation
          raise NotImplementedError
        end

        private

        def method_missing(meth, *args, &block)
          trace.__send__(meth, *args, &block)
        end
      end
    end
  end
end
