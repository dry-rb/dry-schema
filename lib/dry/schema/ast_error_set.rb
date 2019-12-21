# frozen_string_literal: true

require 'dry/schema/error_set'

module Dry
  module Schema
    # A set of AST errors used to generate machine-readable errors
    #
    # @see Result#message_set
    #
    # @api public
    class AstErrorSet < ErrorSet
      private

      # @api private
      def errors_map(errors = self.errors)
        errors
      end
    end
  end
end
