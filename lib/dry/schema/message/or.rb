# frozen_string_literal: true

require 'dry/equalizer'

module Dry
  module Schema
    # Message objects used by message sets
    #
    # @api public
    class Message
      # A message sub-type used by OR operations
      #
      # @api public
      class Or
        # @api private
        attr_reader :left

        # @api private
        attr_reader :right

        # @api private
        attr_reader :path

        # @api private
        attr_reader :messages

        # @api private
        def initialize(left, right, messages)
          @left = left
          @right = right
          @messages = messages
          @path = left.path
        end

        # Return a string representation of the message
        #
        # @api public
        def to_s
          to_a.join(" #{messages[:or]} ")
        end

        # @api private
        def to_a
          [left, right]
        end
      end
    end
  end
end
