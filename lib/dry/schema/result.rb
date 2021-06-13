# frozen_string_literal: true

require "dry/initializer"
require "dry/core/equalizer"

require "dry/schema/path"

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

      # A list of failure ASTs produced by rule result objects
      #
      # @api private
      option :result_ast, default: -> { EMPTY_ARRAY.dup }

      # @api private
      option :message_compiler

      # @api private
      option :parent, default: -> { nil }

      # @api private
      option :path, default: -> { Path.new([]) }

      # @api private
      def self.new(*, **)
        result = super
        yield(result) if block_given?
        result.freeze
      end

      # Return a new result scoped to a specific path
      #
      # @param path [Symbol, Array, Path]
      #
      # @return [Result]
      #
      # @api private
      def at(at_path, &block)
        at_path = Path[at_path]

        if at_path.any?
          return new(@output, parent: parent || self, path: Path.new([*path, *at_path]), &block)
        end

        yield(self) if block_given?
        self
      end

      # @api private
      def new(output, **opts, &block)
        self.class.new(
          output,
          message_compiler: message_compiler,
          result_ast: result_ast,
          **opts,
          &block
        )
      end

      # @api private
      def update(hash)
        output.update(hash)
        self
      end

      def dig(*path)
        path.reduce(@output) { |output, key| output.fetch(key) }
      end

      def output
        dig(*path)
      end

      # Dump result to a hash returning processed and validated data
      #
      # @return [Hash]
      alias_method :to_h, :output

      # @api private
      def replace(value)
        if value.is_a?(output.class)
          output.replace(value)
        elsif parent.nil?
          @output = value
        else
          dig(*path.without_index)[path.last] = value
        end

        self
      end

      # @api private
      def concat(other)
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
        result_ast.empty?
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
        "#<#{self.class}#{to_h.inspect} errors=#{errors.to_h.inspect} path=#{path.keys.inspect}>"
      end

      if RUBY_VERSION >= "2.7"
        # Pattern matching support
        #
        # @api private
        def deconstruct_keys(_)
          output
        end
      end

      # Add a new error AST node
      #
      # @api private
      def add_error(node)
        result_ast << node
      end
    end
  end
end
