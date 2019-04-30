# frozen_string_literal: true

require 'pathname'
require 'dry/core/constants'

module Dry
  # Common constants used across the library
  #
  # @api public
  module Schema
    include Core::Constants

    LIST_SEPARATOR = ', '
    QUESTION_MARK = '?'
    DOT = '.'

    # Path to the default set of localized messages bundled within the gem
    DEFAULT_MESSAGES_PATH = Pathname(__dir__).join('../../../config/errors.yml').realpath.freeze

    # Default namespace used for localized messages in YAML files
    DEFAULT_MESSAGES_ROOT = 'dry_schema'

    # An error raised when DSL is used in an incorrect way
    InvalidSchemaError = Class.new(StandardError)

    # An error raised when a localized message cannot be found
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
