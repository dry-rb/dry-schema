# frozen_string_literal: true

require "dry/core/equalizer"
require "dry/initializer"

module Dry
  module Schema
    # Used by the processors to coerce values in the input hash
    #
    # @api private
    class ValueCoercer
      extend ::Dry::Initializer
      include ::Dry::Equalizer(:type_schema)

      # @api private
      param :type_schema

      # @api private
      def call(input)
        if input.success?
          type_schema[input.to_h]
        else
          error_paths = input.message_set.map(&:path)

          type_schema.each_with_object(EMPTY_HASH.dup) do |key, hash|
            name = key.name

            next unless input.key?(name)

            hash[name] = coerce(key, input[name], error_paths_under(name, error_paths))
          end
        end
      end

      private

      # @api private
      def error_paths_under(name, error_paths)
        error_paths.filter_map { |path| path[1..] if path[0].eql?(name) }
      end

      # Coerce a value, leaving the values that failed validation untouched
      #
      # @api private
      def coerce(key, value, error_paths)
        return key[value] if error_paths.empty?
        return value if error_paths.any?(&:empty?)

        coerced = key[value]

        return value unless coerced.instance_of?(value.class)

        error_paths.each { |path| restore(coerced, value, path) }

        coerced
      end

      # Put back the original value found under the given path
      #
      # @api private
      def restore(target, source, path)
        *parents, last = path

        reachable = parents.all? { |segment|
          next false unless dig?(target, segment) && dig?(source, segment)

          target = target[segment]
          source = source[segment]
          true
        }

        target[last] = source[last] if reachable && dig?(target, last) && dig?(source, last)
      end

      # @api private
      def dig?(container, segment)
        case container
        when ::Hash then container.key?(segment)
        when ::Array then segment.is_a?(::Integer) && segment < container.size
        else false
        end
      end
    end
  end
end
