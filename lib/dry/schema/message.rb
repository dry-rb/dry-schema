# frozen_string_literal: true

require 'dry/initializer'
require 'dry/equalizer'

require 'dry/schema/path'
require 'dry/schema/message/or'

module Dry
  module Schema
    # Message objects used by message sets
    #
    # @api public
    class Message
      include Dry::Equalizer(:text, :path, :predicate, :input)

      extend Dry::Initializer

      # @!attribute [r] text
      #   Message text representation created from a localized template
      #   @return [String]
      option :text

      # @!attribute [r] path
      #   Path to the value
      #   @return [String]
      option :path

      # @!attribute [r] predicate
      #   Predicate identifier that was used to produce a message
      #   @return [Symbol]
      option :predicate

      # @!attribute [r] args
      #   Optional list of arguments used by the predicate
      #   @return [Array]
      option :args, default: proc { EMPTY_ARRAY }

      # @!attribute [r] input
      #   The input value
      #   @return [Object]
      option :input

      # @!attribute [r] meta
      #   Arbitrary meta data
      #   @return [Hash]
      option :meta, optional: true, default: proc { EMPTY_HASH }

      # Dump the message to a representation suitable for the message set hash
      #
      # @return [String,Hash]
      #
      # @api public
      def dump
        @dump ||= meta.empty? ? text : { text: text, **meta }
      end
      alias to_s dump

      # See if another message is the same
      #
      # If a string is passed, it will be compared with the text
      #
      # @param [Message,String]
      #
      # @return [Boolean]
      #
      # @api private
      def eql?(other)
        other.is_a?(String) ? text == other : super
      end

      # See which message is higher in the hierarchy
      #
      # @api private
      def <=>(other)
        l_path = Path[path]
        r_path = Path[other.path]

        unless l_path.same_root?(r_path)
          raise ArgumentError, 'Cannot compare messages from different root paths'
        end

        l_path <=> r_path
      end
    end
  end
end
