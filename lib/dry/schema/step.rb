# frozen_string_literal: true

require "dry/schema/constants"
require "dry/schema/path"

module Dry
  module Schema
    # @api private
    class Step
      EMPTY_PATH = Path.new([]).freeze
      private_constant :EMPTY_PATH

      # @api private
      attr_reader :name

      # @api private
      attr_reader :type

      # @api private
      attr_reader :executor

      # @api private
      attr_reader :path

      # @api private
      def initialize(type:, name:, executor:, path: EMPTY_PATH)
        @type = type
        @name = name
        @executor = executor
        @path = path
        validate_name(name)
      end

      # @api private
      def call(result)
        scoped_results(result).each do |scoped_result|
          output = executor.(scoped_result)
          scoped_result.replace(output) if output.is_a?(Hash)
        end
      end

      # @api private
      def scoped_results(initial_result)
        path.reduce([initial_result]) do |results, path_key|
          results.flat_map do |result|
            next unless result.output.key?(path_key)

            scoped_result = result.at(path_key)

            next scoped_result unless scoped_result.output.is_a?(Array)

            Array.new(scoped_result.output.length) { |index| scoped_result.at(index) }
          end.compact
        end
      end

      # @api private
      def scoped(parent_path)
        self.class.new(
          type: type,
          name: name,
          executor: executor,
          path: Path.new([*parent_path, *path])
        )
      end

      private

      # @api private
      def validate_name(name)
        return if STEPS_IN_ORDER.include?(name)

        raise ArgumentError, "Undefined step name #{name}. Available names: #{STEPS_IN_ORDER}"
      end
    end
  end
end
