# frozen_string_literal: true

require 'pathname'
require 'dry/core/constants'

module Dry
  module Schema
    include Core::Constants

    LIST_SEPARATOR = ', '
    QUESTION_MARK = '?'
    DOT = '.'

    DEFAULT_MESSAGES_PATH = Pathname(__dir__).join('../../../config/errors.yml').realpath.freeze
    DEFAULT_MESSAGES_ROOT = 'dry_schema'

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
