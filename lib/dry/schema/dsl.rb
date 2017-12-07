require 'dry/schema/macros'

module Dry
  module Schema
    class DSL < BasicObject
      include ::Dry::Equalizer(:compiler, :traces)

      attr_reader :compiler

      attr_reader :macros

      attr_reader :options

      def initialize(compiler, options = {}, &block)
        @macros = []
        @compiler = compiler
        @options = options
        instance_eval(&block) if block
      end

      def class
        ::Dry::Schema::DSL
      end

      def call
        macros.map { |m| [m.name, m.to_rule] }.to_h
      end

      def required(name)
        macro = Macros::Required.new(name, compiler: compiler)
        macros << macro
        macro
      end
    end
  end
end
