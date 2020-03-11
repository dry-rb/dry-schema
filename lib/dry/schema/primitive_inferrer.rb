# frozen_string_literal: true

require "dry/types/primitive_inferrer"

module Dry
  module Schema
    # @api private
    class PrimitiveInferrer < ::Dry::Types::PrimitiveInferrer
      Compiler = ::Class.new(superclass::Compiler)

      def initialize
        @compiler = Compiler.new
      end
    end
  end
end
