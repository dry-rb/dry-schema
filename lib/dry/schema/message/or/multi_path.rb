# frozen_string_literal: true

require "dry/core/equalizer"

require "dry/schema/message/or/abstract"
require "dry/schema/path"

module Dry
  module Schema
    class Message
      module Or
        # A message type used by OR operations with different paths
        #
        # @api public
        class MultiPath < Abstract
          # @api private
          attr_reader :root

          # @api private
          def initialize(...)
            super
            flat_left = left.flatten
            flat_right = right.flatten
            @root = [*flat_left, *flat_right].map(&:_path).reduce(:&)
            @left = flat_left.map { _1.to_or(root) }
            @right = flat_right.map { _1.to_or(root) }
          end

          # @api public
          def to_h
            @to_h ||= Path[[*root, :or]].to_h(
              [MessageSet.new(left).to_h, MessageSet.new(right).to_h]
            )
          end
        end
      end
    end
  end
end
