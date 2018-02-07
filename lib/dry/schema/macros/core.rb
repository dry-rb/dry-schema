require 'dry/schema/definition'
require 'dry/schema/compiler'
require 'dry/schema/trace'

module Dry
  module Schema
    module Macros
      class Core
        attr_reader :name

        attr_reader :compiler

        attr_reader :trace

        attr_reader :block

        attr_reader :options

        def initialize(name, options = {})
          @name = name
          @compiler = options.fetch(:composer) { Compiler.new }
          @trace = options.fetch(:trace) { Trace.new(compiler) }
          @block = options.fetch(:block, &Proc.new {})
          @options = options
        end

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

        def filled(*args, **opts, &block)
          value(:filled?, *args, **opts, &block)
        end

        def schema(&block)
          trace << ::Dry::Schema::Definition.new(compiler, &block)
        end

        def to_rule
          [compiler.visit(to_ast), trace.to_rule(name)].compact.reduce(operation)
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
