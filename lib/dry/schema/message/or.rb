# frozen_string_literal: true

require "dry/schema/message/or/single_path"
require "dry/schema/message/or/multi_path"

module Dry
  module Schema
    # Message objects used by message sets
    #
    # @api public
    class Message
      module Or
        # @api private
        def self.[](left, right, messages)
          msgs = [left, right].flatten
          paths = msgs.map(&:path)

          if paths.uniq.size == 1
            l = left.is_a?(Array) && left.size == 1 ? left.first : left
            r = right.is_a?(Array) && right.size == 1 ? right.first : right
            SinglePath.new(l, r, messages)
          elsif right.is_a?(Array)
            if (left.is_a?(Array) || left.kind_of?(Or::Abstract)) && paths.uniq.size > 1
              MultiPath.new(left, right)
            else
              right
            end
          else
            msgs.max
          end
        end
      end
    end
  end
end
