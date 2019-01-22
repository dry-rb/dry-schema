require 'dry/equalizer'
require 'dry/core/cache'
require 'dry/schema/constants'
require 'dry/schema/key'

module Dry
  module Schema
    class KeyMap
      extend Dry::Core::Cache

      include Dry.Equalizer(:keys)
      include Enumerable

      attr_reader :keys

      def self.[](*keys)
        new(keys)
      end

      def self.new(*args)
        fetch_or_store(*args) { super }
      end

      def initialize(keys)
        @keys = keys.map { |key|
          case key
          when Hash
            root, rest = key.flatten
            Key::Hash[root, members: KeyMap[*rest]]
          when Array
            root, rest = key
            Key::Array[root, member: KeyMap[*rest]]
          when Key
            key
          else
            Key[key]
          end
        }
      end

      def write(source, target = EMPTY_HASH.dup)
        each { |key| key.write(source, target) }
        target
      end

      def coercible(&coercer)
        self.class.new(map { |key| key.coercible(&coercer) })
      end

      def stringified
        self.class.new(map(&:stringified))
      end

      def each(&block)
        keys.each(&block)
      end

      def +(other)
        self.class.new(keys + other.to_a)
      end
    end
  end
end