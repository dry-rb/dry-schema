require 'dry/logic/predicates'

module Dry
  module Schema
    class PredicateRegistry
      attr_reader :predicates

      def initialize(predicates = Dry::Logic::Predicates)
        @predicates = predicates
      end

      def [](name)
        predicates[name]
      end

      def key?(name)
        predicates.respond_to?(name)
      end

      def arg_list(name, *values)
        predicate = self[name]

        predicate
          .parameters
          .map(&:last)
          .zip(values + Array.new(predicate.arity - values.size, Undefined))
      end
    end
  end
end
