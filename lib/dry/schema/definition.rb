require 'dry/schema/dsl'
require 'dry/schema/result'

module Dry
  module Schema
    class Definition
      # Define a new schema definition
      #
      # @return [Definition]
      #
      # @api public
      def self.new(compiler, &block)
        dsl = DSL.new(compiler, &block)
        super(dsl.call)
      end

      attr_reader :rules

      def initialize(rules)
        @rules = rules
      end

      def call(input)
        results = rules.reduce([]) { |a, (name, rule)|
          result = rule.(input)
          a << result unless result.success?
          a
        }

        Result.new(input, results || [])
      end
    end
  end
end
