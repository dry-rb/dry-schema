module Dry
  module Schema
    class NamespacedRule
      attr_reader :rule

      attr_reader :namespace

      def initialize(namespace, rule)
        @namespace = namespace
        @rule = rule
      end

      def call(input)
        result = rule.call(input)
        Logic::Result.new(result.success?) { [:namespace, [namespace, result.to_ast]] }
      end

      def ast(input=Undefined)
        [:namespace, [namespace, rule.ast(input)]]
      end
    end
  end
end
