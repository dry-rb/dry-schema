# frozen_string_literal: true

module Dry
  module Schema
    module Extensions
      module Hints
        module ResultMethods
          # @see Result#errors
          #
          # @api public
          def errors(options = EMPTY_HASH)
            message_set(options.merge(hints: false))
          end

          # Get all messages including hints
          #
          # @see #message_set
          #
          # @return [Hash<Symbol=>Array>]
          #
          # @api public
          def messages(options = EMPTY_HASH)
            message_set(options)
          end

          # Get hints exclusively without errors
          #
          # @see #message_set
          #
          # @return [Hash<Symbol=>Array>]
          #
          # @api public
          def hints(options = EMPTY_HASH)
            message_set(options.merge(failures: false))
          end
        end
      end
    end
  end
end
