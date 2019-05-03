# frozen_string_literal: true

require 'dry/schema/constants'

module Dry
  module Schema
    # Path represents a list of keys in a hash
    #
    # @api private
    class Path
      include Comparable
      include Enumerable

      # @return [Array<Symbol>]
      attr_reader :keys

      alias_method :root, :first

      # Coerce a spec into a path object
      #
      # @param [Path, Symbol, String, Hash, Array<Symbol>] spec
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
        when Path
          spec
        else
          raise ArgumentError, '+spec+ must be either a Symbol, Array, Hash or a Path'
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
      def each(&block)
        keys.each(&block)
      end

      # @api private
      def index(key)
        keys.index(key)
      end

      # @api private
      def include?(other)
        return false unless same_root?(other)
        return false if index? && other.index? && !last.equal?(other.last)
        self >= other
      end

      # @api private
      def <=>(other)
        raise ArgumentError, "Can't compare paths from different branches" unless same_root?(other)

        return 0 if keys.eql?(other.keys)

        res =
          map { |key| (idx = other.index(key)) && keys[idx].equal?(key) }
            .compact
            .reject { |value| value.equal?(false) }

        res.size < count ? 1 : -1
      end

      # @api private
      def last
        keys.last
      end

      # @api private
      def same_root?(other)
        root.equal?(other.root)
      end

      # @api private
      def index?
        last.is_a?(Integer)
      end
    end
  end
end
