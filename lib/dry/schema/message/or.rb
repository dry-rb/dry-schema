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

        # Dump a message into a string
        #
        # @see Message#dump
        #
        # @return [String]
        #
        # @api public
        def dump
          to_a.map(&:dump).join(" #{messages[:or][:text]} ")
        end
        alias to_s dump

        # @api private
        def to_a
          [left, right]
        end
      end
    end
  end
end
