# frozen_string_literal: true

require 'dry/initializer'

module Dry
  module Schema
    # Steps for the Dry::Schema::Processor
    #
    # There are 4 main steps:
    #
    #   1. `key_coercer` - Prepare input hash using a key map
    #   2. `filter_schema` - Apply pre-coercion filtering rules
    #      (optional step, used only when `filter` was used)
    #   3. `value_coercer` - Apply value coercions based on type specifications
    #   4. `rule_applier` - Apply rules
    #
    # @see Processor
    #
    # @api public
    class ProcessorSteps
      extend Dry::Initializer

      STEPS_IN_ORDER = %i[key_coercer filter_schema value_coercer rule_applier].freeze

      option :steps, default: -> { EMPTY_HASH.dup }
      option :before_steps, default: -> { EMPTY_HASH.dup }
      option :after_steps, default: -> { EMPTY_HASH.dup }

      # Executes steps and callbacks in order
      #
      # @param [Result] result
      #
      # @return [Result]
      #
      # @api public
      def call(result)
        STEPS_IN_ORDER.each do |name|
          before_steps[name]&.each { |step| process_step(step, result) }
          process_step(steps[name], result)
          after_steps[name]&.each { |step| process_step(step, result) }
        end
        result
      end

      # Returns step by name
      #
      # @param [Symbol] name The step name
      #
      # @api public
      def [](name)
        steps[name]
      end

      # Sets step by name
      #
      # @param [Symbol] name The step name
      #
      # @api public
      def []=(name, value)
        validate_step_name(name)
        steps[name] = value
      end

      # Add passed block before mentioned step
      #
      # @param [Symbol] name The step name
      #
      # @return [ProcessorSteps]
      #
      # @api public
      def after(name, &block)
        validate_step_name(name)
        after_steps[name] ||= EMPTY_ARRAY.dup
        after_steps[name] << block.to_proc
        self
      end

      # Add passed block before mentioned step
      #
      # @param [Symbol] name The step name
      #
      # @return [ProcessorSteps]
      #
      # @api public
      def before(name, &block)
        validate_step_name(name)
        before_steps[name] ||= EMPTY_ARRAY.dup
        before_steps[name] << block.to_proc
        self
      end

      # @api private
      def process_step(step, result)
        return unless step

        output = step.(result)
        result.replace(output) if output.is_a?(::Hash)
      end

      # @api private
      def validate_step_name(name)
        return if STEPS_IN_ORDER.include?(name)

        raise ArgumentError, "Undefined step name #{name}. Available names: #{STEPS_IN_ORDER}"
      end

      # @api private
      def initialize_copy(source)
        super
        @steps = source.steps.dup
        @before_steps = source.before_steps.dup
        @after_steps = source.after_steps.dup
      end
    end
  end
end
