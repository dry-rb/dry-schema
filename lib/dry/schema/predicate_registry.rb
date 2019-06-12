# frozen_string_literal: true

require 'dry/logic/predicates'

module Dry
  module Schema
    # A registry with predicate objects from `Dry::Logic::Predicates`
    #
    # @api private
    class PredicateRegistry
      # @api private
      attr_reader :predicates

      # @api private
      attr_reader :has_predicate

      # @api private
      def initialize(predicates = Dry::Logic::Predicates)
        @predicates = predicates
        @has_predicate = ::Kernel.instance_method(:respond_to?).bind(@predicates)
      end

      # @api private
      def [](name)
        predicates[name]
      end

      # @api private
      def key?(name)
        has_predicate.(name)
      end

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
