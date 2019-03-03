require 'dry/monads/result'

module Dry
  module Schema
    class Result
      include Dry::Monads::Result::Mixin

      def to_monad(options = EMPTY_HASH)
        if success?
          Success(output)
        else
          Failure(message_set(options).dump)
        end
      end
    end
  end
end
