# frozen_string_literal: true

require 'dry/schema/macros/schema'

module Dry
  module Schema
    module Macros
      # Macro used to specify a nested schema
      #
      # @api public
      class Hash < Schema
        # @api private
        def call(*args, &block)
          trace << hash?
          super(*args, &block)
          self
        end
      end
    end
  end
end
