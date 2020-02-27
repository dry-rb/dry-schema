# frozen_string_literal: true

require 'dry/initializer'
require 'dry/schema/constants'

module Dry
  module Schema
    module Messages
      # @api private
      class Template
        extend Dry::Initializer

        option :messages
        option :key
        option :text
        option :options

        # @api private
        def data(input = EMPTY_HASH)
          messages.pruned_data(self, **input)
        end

        # @api private
        def call(data = EMPTY_HASH)
          messages.interpolate(self, **data)
        end
        alias_method :[], :call
      end
    end
  end
end
