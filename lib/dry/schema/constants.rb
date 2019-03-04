# frozen_string_literal: true

require 'dry/core/constants'

module Dry
  module Schema
    include Core::Constants

    InvalidSchemaError = Class.new(StandardError)
    MissingMessageError = Class.new(StandardError)

    QUESTION_MARK = '?'.freeze
    DOT = '.'.freeze
  end
end
