# frozen_string_literal: true

require 'dry/equalizer'

module Dry
  module Schema
    # A set of messages used to generate errors
    #
    # @see Result#message_set
    #
    # @api public
    class MessageSet
      include Enumerable
      include Dry::Equalizer(:messages, :options)

      # A list of compiled message objects
      #
      # @return [Array<Message>]
      attr_reader :messages
      
      # An internal hash that is filled in with dumped messages
      # when a message set is coerced to a hash
      #
      # @return [Hash<Symbol=>[Array,Hash]>]
      attr_reader :placeholders
      
      # Options hash
      #
      # @return [Hash]
      attr_reader :options

      # @api private
      def self.[](messages, options = EMPTY_HASH)
        new(messages.flatten, options)
      end

      # @api private
      def initialize(messages, options = EMPTY_HASH)
        @messages = messages
        @options = options
        initialize_placeholders!
      end

      # Iterate over messages
      #
      # @example
      #   result.errors.each do |message|
      #     puts message.text
      #   end
      #
      # @return [Array]
      #
      # @api public
      def each(&block)
        return self if empty?
        return to_enum unless block

        messages.each(&block)
      end

      # Dump message set to a hash
      #
      # @return [Hash<Symbol=>Array<String>>]
      #
      # @api public
      def to_h
        @to_h ||= messages_map
      end
      alias_method :to_hash, :to_h

      # Get a list of message texts for the given key
      #
      # @param [Symbol] key
      #
      # @return [Array<String>]
      #
      # @api public
      def [](key)
        to_h[key]
      end

      # Get a list of message texts for the given key
      #
      # @param [Symbol] key
      #
      # @return [Array<String>]
      #
      # @raise KeyError
      #
      # @api public
      def fetch(key)
        self[key] || raise(KeyError, "+#{key}+ message was not found")
      end

      # Check if a message set is empty
      #
      # @return [Boolean]
      #
      # @api public
      def empty?
        @empty ||= messages.empty?
      end

      # @api private
      def freeze
        to_h
        empty?
        super
      end

      private

      # @api private
      def messages_map(messages = self.messages)
        return EMPTY_HASH if empty?

        messages.group_by(&:path).reduce(placeholders) do |hash, (path, msgs)|
          node = path.reduce(hash) { |a, e| a[e] }

          msgs.each do |msg|
            node << msg
          end

          node.map!(&:dump)

          hash
        end
      end

      # @api private
      def paths
        @paths ||= messages.map(&:path).uniq
      end

      # @api private
      def initialize_placeholders!
        return @placeholders = EMPTY_HASH if empty?

        @placeholders = paths.reduce(EMPTY_HASH.dup) do |hash, path|
          curr_idx = 0
          last_idx = path.size - 1
          node = hash

          while curr_idx <= last_idx
            key = path[curr_idx]
            node = (node[key] || node[key] = curr_idx < last_idx ? {} : [])
            curr_idx += 1
          end

          hash
        end
      end
    end
  end
end
