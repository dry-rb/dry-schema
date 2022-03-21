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
            @left = Array(left).map { |msg| msg.to_or(root) }
            @right = Array(right).map { |msg| msg.to_or(root) }
          end

          def to_or(_root)
            self
          end

          # @api public
          def to_h
            @to_h ||= Path[[*root, :or]].to_h(
              [merge_side(left), merge_side(right)].flatten
            )
          end

          alias _path root

          def path
            to_h
          end

          protected

          def merge_side(side)
            side.map do |element|
              if element.is_a?(MultiPath)
                [merge_side(element.left), merge_side(element.right)]
              else
                element.to_h
              end
            end.reduce(&:merge)
          end
        end
      end
    end
  end
end
