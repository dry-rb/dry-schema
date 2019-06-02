# frozen_string_literal: true

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
