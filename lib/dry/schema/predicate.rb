require 'dry/equalizer'
require 'dry/logic/operators'

module Dry
  module Schema
    class Predicate
      class Negation
        attr_reader :predicate

        def initialize(predicate)
          @predicate = predicate
        end

        def to_ast(*args)
          [:not, predicate.to_ast(*args)]
        end
        alias_method :ast, :to_ast
      end

      include Dry::Logic::Operators
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

      def !
        Negation.new(self)
      end

      def ensure_valid
        if compiler.predicates[name].arity - 1 != args.size
          raise ArgumentError, "#{name} predicate arity is invalid"
        end
      end

      def to_rule
        compiler.visit(to_ast)
      end

      def to_ast(*)
        [:predicate, [name, compiler.predicates.arg_list(name, *args)]]
      end
      alias_method :ast, :to_ast
    end
  end
end
