require 'dry/equalizer'

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

        # @api private
        def hint?
          false
        end

        # Return a string representation of the message
        #
        # @api public
        def to_s
          [left, right].uniq.join(" #{messages[:or].()} ")
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
      def hint?
        false
      end

      # @api private
      def eql?(other)
        other.is_a?(String) ? text == other : super
      end
    end

    # A hint message sub-type
    #
    # @api private
    class Hint < Message
      def self.[](predicate, path, text, options)
        Hint.new(predicate, path, text, options)
      end

      # @api private
      def hint?
        true
      end
    end
  end
end
