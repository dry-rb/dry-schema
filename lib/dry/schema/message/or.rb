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
            SinglePath.new(left, right, messages)
          elsif right.is_a?(Array)
            if left.is_a?(Array) && paths.uniq.size > 1
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
