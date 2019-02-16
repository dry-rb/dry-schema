require 'dry/schema/constants'

module Dry
  module Schema
    # Path represents a list of keys in a hash
    #
    # @api private
    class Path
      # !@attribute [r] keys
      #   @return [Array<Symbol>]
      attr_reader :keys

      # Coerce a spec into a path object
      #
      # @param [Symbol, String, Hash, Array<Symbol>] spec
      #
      # @return [Path]
      #
      # @api private
      def self.[](spec)
        case spec
        when Symbol, Array
          new(Array[*spec])
        when String
          new(spec.split(DOT).map(&:to_sym))
        when Hash
          new(keys_from_hash(spec))
        when self
          spec
        else
          raise ArgumentError, '+spec+ must be either a Symbol, Array or Hash'
        end
      end

      # Extract a list of keys from a hash
      #
      # @api private
      def self.keys_from_hash(hash)
        hash.inject([]) { |a, (k, v)|
          v.is_a?(Hash) ? a.concat([k, *keys_from_hash(v)]) : a.concat([k, v])
        }
      end

      # @api private
      def initialize(keys)
        @keys = keys
      end

      # @api private
      def ==(other)
        keys == Path[other].keys
      end
    end
  end
end
