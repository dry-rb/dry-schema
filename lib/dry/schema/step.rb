# frozen_string_literal: true

require "dry/schema/constants"
require "dry/schema/path"

module Dry
  module Schema
    # @api private
    class Step
      # @api private
      attr_reader :name

      # @api private
      attr_reader :type

      # @api private
      attr_reader :executor

      # @api private
      class Scoped
        # @api private
        attr_reader :path

        # @api private
        attr_reader :step

        # @api private
        def initialize(path, step)
          @path = Path[path]
          @step = step
        end

        # @api private
        def scoped(new_path)
          self.class.new(Path[[*new_path, *path]], step)
        end

        # @api private
        def call(result)
          result.at(path) do |scoped_result|
            output = step.(scoped_result).to_h
            target = Array(path)[0..-2].reduce(result) { |a, e| a[e] }

            target.update(path.last => output)
          end
        end
      end

      # @api private
      def initialize(type:, name:, executor:)
        @type = type
        @name = name
        @executor = executor
        validate_name(name)
      end

      # @api private
      def call(result)
        output = executor.(result)
        result.replace(output) if output.is_a?(Hash)
        output
      end

      # @api private
      def scoped(path)
        Scoped.new(path, self)
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
