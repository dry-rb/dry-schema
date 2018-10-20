require 'dry/monads/result'

module Dry
  module Schema
    class Result
      include Dry::Monads::Result::Mixin

      def to_monad(options = EMPTY_HASH)
        if success?
          Success(output)
        else
          Failure(messages(options))
        end
      end
      alias_method :to_result, :to_monad
    end
  end
end
