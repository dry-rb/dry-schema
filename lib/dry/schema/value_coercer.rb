# frozen_string_literal: true

require 'dry/equalizer'
require 'dry/initializer'

module Dry
  module Schema
    # Used by the processors to coerce values in the input hash
    #
    # @api private
    class ValueCoercer
      extend Dry::Initializer
      include ::Dry::Equalizer(:type_schema)

      # @api private
      param :type_schema

      # @api private
      def call(input)
        if input.success?
          type_schema[Hash(input)]
        else
          type_schema.each_with_object(EMPTY_HASH.dup) do |key, hash|
            name = key.name
            value = input[name]

            hash[name] = input.error?(name) ? value : key[value]
          end
        end
      end
    end
  end
end
