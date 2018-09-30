require 'dry/types'
require 'dry/types/compat'

module Dry
  # <TODO>: figure out what to do with these helpers
  class Types::Sum
    def maybe?
      left.primitive == NilClass
    end

    def hash?
      right.primitive == Hash
    end

    def array?
      right.primitive == Array
    end
  end

  class Types::Definition
    def maybe?
      false
    end

    def hash?
      primitive == Hash
    end

    def array?
      primitive == Array
    end
  end
  # </TODO>

  module Schema
    module Types
      include Dry::Types.module
    end
  end
end
