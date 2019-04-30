# frozen_string_literal: true

require 'dry/initializer'
require 'dry/equalizer'

require 'dry/schema/path'

module Dry
  module Schema
    # Processing result
    #
    # @see Processor#call
    #
    # @api public
    class Result
      include Dry::Equalizer(:output, :errors)

      extend Dry::Initializer

      # @api private
      param :output

      # Dump result to a hash returning processed and validated data
      #
      # @return [Hash]
      alias_method :to_h, :output

      # @api private
      param :results, default: -> { EMPTY_ARRAY.dup }

      # @api private
      option :message_compiler

      # @api private
      def self.new(*args)
        result = super
        yield(result)
        result.freeze
      end

      # @api private
      def replace(hash)
        @output = hash
        self
      end

      # @api private
      def concat(other)
        results.concat(other)
        result_ast.concat(other.map(&:to_ast))
        self
      end

      # Read value from the output hash
      #
      # @param [Symbol] name
      #
      # @return [Object]
      #
      # @api public
      def [](name)
        output[name]
      end

      # Check if a given key is present in the output
      #
      # @param [Symbol] name
      #
      # @return [Boolean]
      #
      # @api public
      def key?(name)
        output.key?(name)
      end

      # Check if there's an error for the provided spec
      #
      # @param [Symbol, Hash<Symbol=>Symbol>] spec
      #
      # @return [Boolean]
      #
      # @api public
      def error?(spec)
        message_set.any? { |msg| Path[msg.path].include?(Path[spec]) }
      end

      # Check if the result is successful
      #
      # @return [Boolean]
      #
      # @api public
      def success?
        results.empty?
      end

      # Check if the result is not successful
      #
      # @return [Boolean]
      #
      # @api public
      def failure?
        !success?
      end

      # Get human-readable error representation
      #
      # @see #message_set
      #
      # @return [MessageSet]
      #
      # @api public
      def errors(options = EMPTY_HASH)
        message_set(options)
      end

      # Return the message set
      #
      # @param [Hash] options
      # @option options [Symbol] :locale Alternative locale (default is :en)
      # @option options [Boolean] :hints Whether to include hint messages or not
      # @option options [Boolean] :full Whether to generate messages that include key names
      #
      # @return [MessageSet]
      #
      # @api public
      def message_set(options = EMPTY_HASH)
        message_compiler.with(options).(result_ast)
      end

      # Return a string representation of the result
      #
      # @return [String]
      #
      # @api public
      def inspect
        "#<#{self.class}#{to_h.inspect} errors=#{errors.to_h.inspect}>"
      end

      private

      # A list of failure ASTs produced by rule result objects
      #
      # @api private
      def result_ast
        @result_ast ||= results.map(&:to_ast)
      end
    end
  end
end
