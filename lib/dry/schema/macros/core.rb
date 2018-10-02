require 'dry/initializer'

require 'dry/schema/constants'
require 'dry/schema/compiler'
require 'dry/schema/trace'

module Dry
  module Schema
    module Macros
      class Core
        extend Dry::Initializer

        option :name, default: proc { nil }, optional: true

        option :compiler, default: proc { Compiler.new }

        option :trace, default: proc { Trace.new }

        option :schema_dsl, optional: true

        def new(options = EMPTY_HASH)
          self.class.new({ name: name, compiler: compiler, schema_dsl: schema_dsl }.merge(options))
        end

        def to_rule
          compiler.visit(to_ast)
        end

        def to_ast(*)
          trace.to_ast
        end
        alias_method :ast, :to_ast

        def operation
          raise NotImplementedError
        end
      end
    end
  end
end
