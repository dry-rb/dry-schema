# frozen_string_literal: true

require "dry/types/predicate_inferrer"

module Dry
  module Schema
    # @api private
    class PredicateInferrer < ::Dry::Types::PredicateInferrer
      Compiler = ::Class.new(superclass::Compiler)

      def initialize(registry = PredicateRegistry.new)
        @compiler = Compiler.new(registry)
      end
    end
  end
end
