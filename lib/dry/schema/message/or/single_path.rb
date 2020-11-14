# frozen_string_literal: true

require "dry/schema/message/or/abstract"

module Dry
  module Schema
    class Message
      module Or
        # A message type used by OR operations with the same path
        #
        # @api public
        class SinglePath < Abstract
          # @api private
          attr_reader :path

          # @api private
          attr_reader :_path

          # @api private
          attr_reader :messages

          # @api private
          def initialize(*args, messages)
            super(*args)
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
            @dump ||= "#{left.dump} #{messages[:or]} #{right.dump}"
          end
          alias_method :to_s, :dump

          # Dump an `or` message into a hash
          #
          # @see Message#to_h
          #
          # @return [String]
          #
          # @api public
          def to_h
            @to_h ||= _path.to_h(dump)
          end

          # @api private
          def to_a
            @to_a ||= [left, right]
          end
        end
      end
    end
  end
end
