# frozen_string_literal: true

require 'dry/equalizer'

module Dry
  module Schema
    # A set of generic errors
    #
    # @see Result#message_set
    #
    # @api public
    class ErrorSet
      include Enumerable
      include Dry::Equalizer(:errors, :options)

      # A list of compiled errors
      #
      # @return [Array<Any>]
      attr_reader :errors

      # Options hash
      #
      # @return [Hash]
      attr_reader :options

      # @api private
      def self.[](errors, options = EMPTY_HASH)
        new(errors, options)
      end

      # @api private
      def initialize(errors, options = EMPTY_HASH)
        @errors = errors
        @options = options
      end

      # Iterate over errors
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

        errors.each(&block)
      end

      # Dump message set to a hash
      #
      # @return [Hash<Symbol=>Array<String>>]
      #
      # @api public
      def to_h
        @to_h ||= errors_map
      end
      alias_method :to_hash, :to_h

      # Get a list of errors for the given key
      #
      # @param [Symbol] key
      #
      # @return [Array<String>]
      #
      # @api public
      def [](key)
        to_h[key]
      end

      # Get a list of errors for the given key
      #
      # @param [Symbol] key
      #
      # @return [Array<String>]
      #
      # @raise KeyError
      #
      # @api public
      def fetch(key)
        self[key] || raise(KeyError, "+#{key}+ error was not found")
      end

      # Check if an error set is empty
      #
      # @return [Boolean]
      #
      # @api public
      def empty?
        @empty ||= errors.empty?
      end

      # @api private
      def freeze
        to_h
        empty?
        super
      end

      # @api private
      def errors_map(_errors)
        raise NotImplementedError
      end
    end
  end
end
