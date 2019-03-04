# frozen_string_literal: true

require 'dry/equalizer'
require 'dry/schema/path'

module Dry
  module Schema
    # Message objects used by message sets
    #
    # @api public
    class Message
      include Dry::Equalizer(:predicate, :path, :text, :options)

      attr_reader :predicate, :path, :text, :rule, :args, :options

      # A message sub-type used by OR operations
      #
      # @api public
      class Or
        include Enumerable

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
          uniq.join(" #{messages[:or].()} ")
        end

        # @api private
        def each(&block)
          to_a.each(&block)
        end

        # @api private
        def to_a
          [left, right]
        end
      end

      # Build a new message object
      #
      # @api private
      def self.[](predicate, path, text, options)
        Message.new(predicate, path, text, options)
      end

      # @api private
      def initialize(predicate, path, text, options)
        @predicate = predicate
        @path = path.dup
        @text = text
        @options = options
        @rule = options[:rule]
        @args = options[:args] || EMPTY_ARRAY

        if predicate == :key?
          @path << rule
        end
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
