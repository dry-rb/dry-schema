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
        attr_reader :_path

        # @api private
        attr_reader :messages

        # @api private
        def self.[](left, right, messages)
          if [left, right].flatten.map(&:path).uniq.size == 1
            new(left, right, messages)
          elsif right.is_a?(Array)
            right
          else
            [left, right].flatten.max
          end
        end

        # @api private
        def initialize(left, right, messages)
          @left = left
          @right = right
          @messages = messages
          @path = left.path
          @_path = left._path
        end

        # Dump a message into a string
        #
        # Both sides of the message will be joined using translated
        # value under `dry_schema.or` message key
        #
        # @see Message#dump
        #
        # @return [String]
        #
        # @api public
        def dump
          "#{left.dump} #{messages[:or][:text]} #{right.dump}"
        end
        alias to_s dump

        # Dump an `or` message into a hash
        #
        # @see Message#to_h
        #
        # @return [String]
        #
        # @api public
        def to_h
          _path.to_h(dump)
        end

        # @api private
        def to_a
          [left, right]
        end
      end
    end
  end
end
