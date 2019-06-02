# frozen_string_literal: true

require 'dry-container'
require 'dry-types'

module Dry
  module Schema
    class TypeContainer
      include Dry::Container::Mixin

      def initialize(types_container = Dry::Types.container)
        super()

        merge(types_container)
      end

      alias registered? key?
    end
  end
end
