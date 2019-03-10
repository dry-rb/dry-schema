# frozen_string_literal: true

require 'dry/configurable'
require 'dry/initializer'

require 'dry/schema/type_registry'
require 'dry/schema/rule_applier'
require 'dry/schema/key_coercer'
require 'dry/schema/value_coercer'

module Dry
  module Schema
    # Processes input data using objects configured within the DSL
    #
    # Processing is split into 4 main steps:
    #
    #   1. Prepare input hash using a key map
    #   2. Apply pre-coercion filtering rules (optional step, used only when `filter` was used)
    #   3. Apply value coercions based on type specifications
    #   4. Apply rules
    #
    # @see Params
    # @see JSON
    #
    # @api public
    class Processor
      extend Dry::Initializer
      extend Dry::Configurable

      setting :key_map_type
      setting :type_registry, TypeRegistry.new

      param :steps, default: -> { EMPTY_ARRAY.dup }

      class << self
        # @!attribute [r] definition
        #   Return DSL configured via #define
        #   @return [DSL]
        #   @api private
        attr_reader :definition

        # Define a schema for your processor class
        #
        # @see Params
        # @see JSON
        #
        # @return [Class]
        #
        # @api public
        def define(&block)
          @definition ||= DSL.new(
            processor_type: self, parent: superclass.definition, **config, &block
          )
          self
        end

        # Build a new processor object
        #
        # @return [Processor]
        #
        # @api public
        def new(&block)
          if block
            super.tap(&block)
          elsif definition
            definition.call
          else
            raise ArgumentError, 'Cannot create a schema without a definition'
          end
        end
      end

      # Append a step
      #
      # @return [Processor]
      #
      # @api private
      def <<(step)
        steps << step
        self
      end

      # Apply processing steps to the provided input
      #
      # @param [Hash] input
      #
      # @return [Result]
      #
      # @api public
      def call(input)
        Result.new(input, message_compiler: message_compiler) do |result|
          steps.each do |step|
            output = step.(result)
            result.replace(output) if output.is_a?(::Hash)
          end
        end
      end

      # Return the key map
      #
      # @return [KeyMap]
      #
      # @api public
      def key_map
        @key_map ||= steps.detect { |s| s.is_a?(KeyCoercer) }.key_map
      end

      # Return the type schema
      #
      # @return [Dry::Types::Safe]
      #
      # @api private
      def type_schema
        @type_schema ||= steps.detect { |s| s.is_a?(ValueCoercer) }.type_schema
      end

      # Return the rules config
      #
      # @return [Dry::Types::Config]
      #
      # @api private
      def config
        @config ||= rule_applier.config
      end

      # Return AST representation of the rules
      #
      # @api private
      def to_ast
        rule_applier.to_ast
      end

      # Return the message compiler
      #
      # @return [MessageCompiler]
      #
      # @api private
      def message_compiler
        rule_applier.message_compiler
      end

      # Return the rules from rule applier
      #
      # @return [MessageCompiler]
      #
      # @api private
      def rules
        rule_applier.rules
      end

      # Return the rule applier
      #
      # @api private
      def rule_applier
        @rule_applier ||= steps.last
      end
      alias_method :to_rule, :rule_applier
    end
  end
end
