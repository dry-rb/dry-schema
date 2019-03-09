# frozen_string_literal: true

require 'dry/core/constants'

module Dry
  module Schema
    include Core::Constants

    LIST_SEPARATOR = ', '
    QUESTION_MARK = '?'
    DOT = '.'

    InvalidSchemaError = Class.new(StandardError)

    MissingMessageError = Class.new(StandardError) do
      # @api private
      def initialize(path)
        *rest, rule = path
        super(<<~STR)
          Message template for #{rule.inspect} under #{rest.join(DOT).inspect} was not found
        STR
      end
    end
  end
end
