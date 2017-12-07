require 'dry/equalizer'

module Dry
  module Schema
    class Predicate
      include Dry::Equalizer(:name, :args, :block)

      attr_reader :compiler

      attr_reader :name

      attr_reader :args

      attr_reader :block

      def initialize(compiler, name, args, block)
        @compiler = compiler
        @name = name
        @args = args
        @block = block
      end

      def to_rule
        compiler.visit(to_ast)
      end

      def to_ast
        [:predicate, [name, compiler.predicates.arg_list(name, *args)]]
      end
    end
  end
end
