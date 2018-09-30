require 'dry/initializer'

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

        option :block, optional: true

        def to_rule
          compiler.visit(to_ast)
        end

        def to_ast
          raise NotImplementedError
        end

        def operation
          raise NotImplementedError
        end
      end
    end
  end
end
