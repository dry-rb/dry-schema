# frozen_string_literal: true

require 'dry/schema/error_compiler'
require 'dry/schema/ast_error_set'

module Dry
  module Schema
    # Compiles rule results AST into machine-readable format
    #
    # @api private
    class AstErrorCompiler < ErrorCompiler
      # @api private
      def call(ast)
        AstErrorSet[ast]
      end
    end
  end
end
