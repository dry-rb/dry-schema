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

      option :text

      option :path

      option :predicate

      option :args, default: proc { EMPTY_ARRAY }

      option :input

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
