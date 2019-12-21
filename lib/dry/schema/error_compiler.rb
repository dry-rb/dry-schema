# frozen_string_literal: true

module Dry
  module Schema
    # Compiles rule results AST into some type of errors
    #
    # @api private
    class ErrorCompiler
      # @api private
      def call(_ast)
        raise NotImplementedError
      end

      # @api private
      def with(*args)
        self
      end
    end
  end
end
