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
        curr_idx = 0
        last_idx = keys.size - 1
        hash = EMPTY_HASH.dup
        node = hash

        while curr_idx <= last_idx
          node =
            node[keys[curr_idx]] =
              if curr_idx == last_idx
                value.is_a?(Array) ? value : [value]
              else
                EMPTY_HASH.dup
              end

          curr_idx += 1
        end

        hash
      end

      # @api private
      def each(&block)
        keys.each(&block)
      end

      # @api private
      def index(key)
        keys.index(key)
      end

      def without_index
        self.class.new(to_a[0..-2])
      end

      # @api private
      def include?(other)
        if !same_root?(other)
          false
        elsif index?
          if other.index?
            last.equal?(other.last)
          else
            without_index.include?(other)
          end
        elsif other.index? && key_matches(other, :select).size < 2
          false
        else
          self >= other && !other.key_matches(self).include?(nil)
        end
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

      # @api private
      def index?
        last.is_a?(Integer)
      end
    end
  end
end
