require 'dry/types'
require 'dry/types/compat'

module Dry
  # <TODO>: figure out what to do with these helpers
  class Types::Sum
    def maybe?
      left.primitive == NilClass
    end

    def hash?
      right.hash?
    end

    def array?
      right.array?
    end

    def member_array?
      right.member_array?
    end

    def member
      right.member
    end

    def member_types
      right.member_types
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

    def member_array?
      array? && respond_to?(:member)
    end
  end
  # </TODO>

  module Schema
    module Types
      include Dry::Types.module
    end
  end
end
