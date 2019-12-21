# frozen_string_literal: true

require 'dry/schema/error_set'

module Dry
  module Schema
    # A set of messages used to generate errors
    #
    # @see Result#message_set
    #
    # @api public
    class MessageSet < ErrorSet
      # An internal hash that is filled in with dumped messages
      # when a message set is coerced to a hash
      #
      # @return [Hash<Symbol=>[Array,Hash]>]
      attr_reader :placeholders
      
      private

      # @api private
      def errors_map(errors = self.errors)
        return EMPTY_HASH if empty?

        initialize_placeholders!
        errors.group_by(&:path).reduce(placeholders) do |hash, (path, msgs)|
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
        @paths ||= errors.map(&:path).uniq
      end

      # @api private
      def initialize_placeholders!
        return @placeholders = EMPTY_HASH if empty?

        @placeholders ||= paths.reduce(EMPTY_HASH.dup) do |hash, path|
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
