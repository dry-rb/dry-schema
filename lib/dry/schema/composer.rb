require 'dry/schema/compiler'
require 'dry/schema/predicate'

module Dry
  module Schema
    class Composer < BasicObject
      include ::Dry::Equalizer(:compiler)

      attr_reader :compiler

      def initialize(compiler = Compiler.new)
        @compiler = compiler
      end

      def class
        ::Dry::Schema::Composer
      end

      private

      def method_missing(meth, *args, &block)
        Predicate.new(compiler, meth, args, block).to_rule
      end
    end
  end
end
