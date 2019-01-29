require 'dry/types'

module Dry
  module Schema
    # Schema's own type registry
    #
    # @api public
    module Types
      include Dry::Types.module
    end
  end
end
