# frozen_string_literal: true

require "dry/schema/constants"

module Dry
  module Schema
    # Path represents a list of keys in a hash
    #
    # @api private
    class Path
      include Dry.Equalizer(:keys)
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
      def self.call(spec)
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
          raise ArgumentError, "+spec+ must be either a Symbol, Array, Hash or a Path"
        end
      end

      # @api private
      def self.[](spec)
        call(spec)
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
      def to_h(value = EMPTY_ARRAY.dup)
        value = [value] unless value.is_a?(Array)

        keys.reverse_each.reduce(value) { |result, key| {key => result} }
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
        keys[0, other.keys.length].eql?(other.keys)
      end

      # @api private
      def <=>(other)
        raise ArgumentError, "Can't compare paths from different branches" unless same_root?(other)

        return 0 if keys.eql?(other.keys)

        res = key_matches(other).compact.reject { |value| value.equal?(false) }

        res.size < count ? 1 : -1
      end

      # @api private
      def &(other)
        unless same_root?(other)
          raise ArgumentError, "#{other.inspect} doesn't have the same root #{inspect}"
        end

        self.class.new(
          key_matches(other, :select).compact.reject { |value| value.equal?(false) }
        )
      end

      # @api private
      def key_matches(other, meth = :map)
        public_send(meth) { |key| (idx = other.index(key)) && keys[idx].equal?(key) }
      end

      # @api private
      def last
        keys.last
      end

      # @api private
      def same_root?(other)
        root.equal?(other.root)
      end
    end
  end
end
