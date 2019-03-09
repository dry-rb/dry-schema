# frozen_string_literal: true

require 'dry/core/constants'

module Dry
  module Schema
    include Core::Constants

    InvalidSchemaError = Class.new(StandardError)
    MissingMessageError = Class.new(StandardError)

    LIST_SEPARATOR = ', '
    QUESTION_MARK = '?'
    DOT = '.'
  end
end
