require 'dry/logic/rule_compiler'
require 'dry/schema/predicate_registry'

module Dry
  module Schema
    # Extended rule compiler used internally by the DSL
    #
    # @api private
    class Compiler < Logic::RuleCompiler
      # Builds a default compiler instance with custom predicate registry
      #
      # @return [Compiler]
      #
      # @api private
      def self.new(predicates = PredicateRegistry.new)
        super
      end

      # Return true if a given predicate is supported by this compiler
      #
      # @param [Symbol] predicate
      #
      # @return [Boolean]
      #
      # @api private
      def supports?(predicate)
        predicates.key?(predicate)
      end
    end
  end
end
