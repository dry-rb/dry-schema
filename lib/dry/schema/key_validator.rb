# frozen_string_literal: true

require "dry/initializer"
require "dry/schema/constants"

module Dry
  module Schema
    # @api private
    class KeyValidator
      extend Dry::Initializer

      INDEX_REGEX = /\[\d+\]/.freeze
      DIGIT_REGEX = /\A\d+\z/.freeze
      BRACKETS = "[]"

      # @api private
      option :key_map

      # @api private
      def call(result)
        input = result.to_h

        input_paths = key_paths(input)
        key_paths = key_map.to_dot_notation

        input_paths.each do |path|
          error_path = validate_path(key_paths, path)

          next unless error_path

          result.add_error([:unexpected_key, [error_path, input]])
        end

        result
      end

      private

      # @api private
      def validate_path(key_paths, path)
        if path[INDEX_REGEX]
          key = path.gsub(INDEX_REGEX, BRACKETS)

          if key_paths.none? { paths_match?(key, _1) }
            arr = path.gsub(INDEX_REGEX) { ".#{_1[1]}" }
            arr.split(DOT).map { DIGIT_REGEX.match?(_1) ? Integer(_1, 10) : _1.to_sym }
          end
        elsif key_paths.none? { paths_match?(path, _1) }
          path
        end
      end

      # @api private
      def paths_match?(input_path, key_path)
        residue = key_path.sub(input_path, "")
        residue.empty? || residue.start_with?(DOT, BRACKETS)
      end

      # @api private
      def key_paths(hash)
        hash.flat_map { |key, value|
          case value
          when ::Hash
            if value.empty?
              [key.to_s]
            else
              [key].product(key_paths(hash[key])).map { _1.join(DOT) }
            end
          when ::Array
            hashes_or_arrays = hashes_or_arrays(value)

            if hashes_or_arrays.empty?
              [key.to_s]
            else
              hashes_or_arrays.flat_map.with_index { |el, idx|
                key_paths(el).map { ["#{key}[#{idx}]", *_1].join(DOT) }
              }
            end
          else
            key.to_s
          end
        }
      end

      # @api private
      def hashes_or_arrays(xs)
        xs.select { |x|
          (x.is_a?(::Array) || x.is_a?(::Hash)) && !x.empty?
        }
      end
    end
  end
end
