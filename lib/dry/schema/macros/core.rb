require 'dry/initializer'

require 'dry/schema/definition'
require 'dry/schema/compiler'
require 'dry/schema/trace'

module Dry
  module Schema
    module Macros
      class Core
        extend Dry::Initializer

        option :compiler, default: proc { Compiler.new }

        option :trace, default: proc { Trace.new }

        option :block, optional: true

        def value(*predicates, **opts, &block)
          predicates.each do |predicate|
            public_send(predicate)
          end

          opts.each do |predicate, *args|
            public_send(predicate, *args)
          end

          if block
            trace.evaluate(&block)
          end

          self
        end

        def filled(*args, &block)
          value(:filled?, *args, &block)
        end

        def schema(&block)
          dsl = ::Dry::Schema::DSL.new(compiler, &block)
          trace << ::Dry::Schema::Definition.new(dsl.call)
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
