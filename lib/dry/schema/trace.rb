require 'dry/schema/compiler'
require 'dry/schema/predicate'

module Dry
  module Schema
    class Trace < BasicObject
      include ::Dry::Equalizer(:compiler, :nodes)

      attr_reader :compiler

      attr_reader :nodes

      def initialize(compiler = Compiler.new)
        @compiler = compiler
        @nodes = []
      end

      def <<(node)
        nodes << node
        self
      end

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
        nodes << Predicate.new(compiler, meth, args, block)
        self
      end

      def method_missing(meth, *args, &block)
        register(meth, *args, block)
      end
    end
  end
end
