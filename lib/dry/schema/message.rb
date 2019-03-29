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
