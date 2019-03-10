# frozen_string_literal: true

module Dry
  module Schema
    module Extensions
      module Hints
        module MessageSetMethods
          attr_reader :hints, :failures

          # @api private
          def initialize(messages, options = EMPTY_HASH)
            super
            @hints = messages.select(&:hint?)
            @failures = options.fetch(:failures, true)
          end

          # @api public
          def to_h
            failures ? messages_map : messages_map(hints)
          end
          alias_method :to_hash, :to_h
        end
      end
    end
  end
end
