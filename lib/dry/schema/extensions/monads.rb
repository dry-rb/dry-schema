# frozen_string_literal: true

require 'dry/monads/result'

module Dry
  module Schema
    class Result
      include Dry::Monads::Result::Mixin

      def to_monad
        if success?
          Success(self)
        else
          Failure(self)
        end
      end
    end
  end
end
