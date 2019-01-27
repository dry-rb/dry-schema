require 'dry/equalizer'
require 'dry/logic/operators'

module Dry
  module Schema
    # Predicate objects used within the DSL
    #
    # @api public
    class Predicate
      # A negated predicate
      #
      # @api private
      class Negation
        # @api private
        attr_reader :predicate

        # @api private
        def initialize(predicate)
          @predicate = predicate
        end

        # @api private
        def to_ast(*args)
          [:not, predicate.to_ast(*args)]
        end
        alias_method :ast, :to_ast
      end

      include Dry::Logic::Operators
      include Dry::Equalizer(:name, :args, :block)

      # @api private
      attr_reader :compiler

      # @api private
      attr_reader :name

      # @api private
      attr_reader :args

      # @api private
      attr_reader :block

      # @api private
      def initialize(compiler, name, args, block)
        @compiler = compiler
        @name = name
        @args = args
        @block = block
      end

      # Negate a predicate
      #
      # @return [Negation]
      #
      # @api public
      def !
        Negation.new(self)
      end

      # @api private
      def ensure_valid
        if compiler.predicates[name].arity - 1 != args.size
          raise ArgumentError, "#{name} predicate arity is invalid"
        end
      end

      # @api private
      def to_rule
        compiler.visit(to_ast)
      end

      # @api private
      def to_ast(*)
        [:predicate, [name, compiler.predicates.arg_list(name, *args)]]
      end
      alias_method :ast, :to_ast
    end
  end
end
