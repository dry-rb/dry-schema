# frozen_string_literal: true

require "dry/logic/predicates"
require "dry/types/predicate_registry"

module Dry
  module Schema
    # A registry with predicate objects from `Dry::Logic::Predicates`
    #
    # @api private
    class PredicateRegistry < Dry::Types::PredicateRegistry
      # @api private
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
