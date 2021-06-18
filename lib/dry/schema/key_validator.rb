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
          error_path =
            if path[INDEX_REGEX]
              key = path.gsub(INDEX_REGEX, BRACKETS)

              if key_paths.none? { |key_path| key_path.include?(key) }
                arr = path.gsub(INDEX_REGEX) { |m| ".#{m[1]}" }
                arr.split(DOT).map { |s| DIGIT_REGEX.match?(s) ? s.to_i : s.to_sym }
              end
            elsif key_paths.none? { |key_path| key_path.include?(path) }
              path
            end

          next unless error_path

          result.add_error([:unexpected_key, [error_path, input]])
        end

        result
      end

      private

      # @api private
      def key_paths(hash)
        hash.flat_map { |key, _|
          case (value = hash[key])
          when Hash
            next key.to_s if value.empty?

            [key].product(key_paths(hash[key])).map { |keys| keys.join(DOT) }
          when Array
            hashes_or_arrays = value.select { |e| (e.is_a?(Array) || e.is_a?(Hash)) && !e.empty? }

            next key.to_s if hashes_or_arrays.empty?

            hashes_or_arrays.flat_map.with_index { |el, idx|
              key_paths(el).map { |path| ["#{key}[#{idx}]", *path].join(DOT) }
            }
          else
            key.to_s
          end
        }
      end
    end
  end
end
