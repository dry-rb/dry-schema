require 'dry/logic/rule_compiler'
require 'dry/schema/predicate_registry'

module Dry
  module Schema
    class Compiler < Logic::RuleCompiler
      def self.new(predicates = PredicateRegistry.new)
        super
      end
    end
  end
end
