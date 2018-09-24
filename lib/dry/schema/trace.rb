require 'dry/schema/compiler'
require 'dry/schema/predicate'

module Dry
  module Schema
    class Trace < BasicObject
      INVALID_PREDICATES = %i[key?].freeze

      include ::Dry::Equalizer(:compiler, :nodes)

      undef eql?

      attr_reader :compiler

      attr_reader :nodes

      def initialize(compiler = Compiler.new)
        @compiler = compiler
        @nodes = []
      end

      def new
        self.class.new(compiler)
      end

      def last
        nodes.last
      end

      def append(node)
        nodes << node
        self
      end
      alias_method :<<, :append

      def to_rule(name = nil)
        return if nodes.empty?

        rule = nodes.map(&:to_rule).reduce(:and)

        if name
          compiler.visit([:key, [name, rule.to_ast]])
        else
          rule
        end
      end

      def to_ast
        nodes.map(&:to_ast)
      end

      def class
        ::Dry::Schema::Trace
      end

      private

      def register(meth, *args, block)
        if ::Dry::Schema::Trace::INVALID_PREDICATES.include?(meth)
          ::Kernel.raise InvalidSchemaError, "#{meth} predicate cannot be used in this context"
        end

        nodes << Predicate.new(compiler, meth, args, block)
        self
      end

      def method_missing(meth, *args, &block)
        register(meth, *args, block).last.to_rule
      end
    end
  end
end
