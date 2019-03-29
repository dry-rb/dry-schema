# frozen_string_literal: true

require 'dry/equalizer'

require 'dry/schema/path'
require 'dry/schema/message/or'

module Dry
  module Schema
    # Message objects used by message sets
    #
    # @api public
    class Message
      include Dry::Equalizer(:predicate, :path, :text, :options)

      attr_reader :predicate, :path, :text, :args, :options

      # Build a new message object
      #
      # @api private
      def self.[](predicate, path, text, options)
        Message.new(predicate, path, text, options)
      end

      # @api private
      def initialize(predicate, path, text, options)
        @predicate = predicate
        @path = path
        @text = text
        @options = options
        @args = options[:args] || EMPTY_ARRAY
      end

      # Return a string representation of the message
      #
      # @api public
      def to_s
        text
      end

      # @api private
      def eql?(other)
        other.is_a?(String) ? text == other : super
      end

      def <=>(other)
        l_path = Path[path]
        r_path = Path[other.path]

        unless l_path.include?(r_path)
          raise ArgumentError, 'Cannot compare messages from different root paths'
        end

        l_path <=> r_path
      end
    end
  end
end
