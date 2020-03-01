# frozen_string_literal: true

require 'dry/initializer'
require 'dry/equalizer'

require 'dry/schema/constants'

module Dry
  module Schema
    module Messages
      # @api private
      class Template
        extend Dry::Initializer
        include Dry::Equalizer(:messages, :key, :options)

        option :messages
        option :key
        option :options

        # @api private
        def data(input = EMPTY_HASH)
          messages.interpolatable_data(self, **options, **input)
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
