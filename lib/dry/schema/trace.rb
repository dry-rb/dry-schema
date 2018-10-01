require 'dry/schema/constants'
require 'dry/schema/compiler'
require 'dry/schema/predicate'

module Dry
  module Schema
    class Trace < BasicObject
      INVALID_PREDICATES = %i[key?].freeze

      include ::Dry::Equalizer(:compiler, :captures)

      undef eql?

      attr_reader :compiler

      attr_reader :captures

      def initialize(compiler = Compiler.new)
        @compiler = compiler
        @captures = []
      end

      def new
        self.class.new(compiler)
      end

      def last
        captures.last
      end

      def evaluate(*predicates, **opts, &block)
        predicates.each do |predicate|
          if predicate.respond_to?(:call)
            append(predicate)
          else
            append(__send__(predicate))
          end
        end

        opts.each do |predicate, *args|
          append(__send__(predicate, *args))
        end

        self
      end

      def append(op)
        captures << op
        self
      end
      alias_method :<<, :append

      def has_rules?
        captures.size.zero?
      end

      def to_rule(name = nil)
        return if captures.empty?

        if name
          compiler.visit([:key, [name, to_ast]])
        else
          reduced_rule
        end
      end

      def to_ast
        reduced_rule.to_ast
      end

      def class
        ::Dry::Schema::Trace
      end

      def respond_to_missing?(meth, include_private = false)
        super || meth.to_s.end_with?(QUESTION_MARK)
      end

      private

      def reduced_rule
        captures.map(&:to_ast).map(&compiler.method(:visit)).reduce(:and)
      end

      def method_missing(meth, *args, &block)
        if meth.to_s.end_with?(QUESTION_MARK)
          if ::Dry::Schema::Trace::INVALID_PREDICATES.include?(meth)
            ::Kernel.raise InvalidSchemaError, "#{meth} predicate cannot be used in this context"
          end

          Predicate.new(compiler, meth, args, block)
        else
          super
        end
      end
    end
  end
end
