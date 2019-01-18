require 'dry/equalizer'

module Dry
  module Schema
    class Key
      include Dry.Equalizer(:name)

      attr_reader :name

      def self.[](name)
        Key.new(name)
      end

      def initialize(name)
        @name = name
      end
    end

    class KeyMap
      include Dry.Equalizer(:keys)
      include Enumerable

      attr_reader :keys

      def self.[](*keys)
        new(keys)
      end

      def initialize(keys)
        @keys = keys.map { |key|
          case key
          when Hash
            root, rest = key.flatten
            { Key[root] => self.class.new(rest) }
          when Array
            root, rest = key
            { Key[root] => [self.class.new(rest)] }
          else
            Key[key]
          end
        }
      end

      def each(&block)
        keys.each(&block)
      end
    end
  end
end