module Dry
  module Schema
    class Key
      extend Dry::Core::Cache

      DEFAULT_COERCER = -> v { v }

      include Dry.Equalizer(:name, :coercer)

      attr_reader :id, :name, :coercer

      def self.[](name, **opts)
        new(name, **opts)
      end

      def self.new(*args)
        fetch_or_store(*args) { super }
      end

      def initialize(id, name: id, coercer: DEFAULT_COERCER)
        @id = id
        @name = name
        @coercer = coercer
      end

      def read(source)
        if source.key?(name)
          yield(source[name])
        elsif source.key?(coerced_name)
          yield(source[coerced_name])
        end
      end

      def write(source, target)
        read(source) { |value| target[coerced_name] = value }
      end

      def coercible(&coercer)
        self.class.new(id, name: name, coercer: coercer)
      end

      def stringified
        self.class.new(id, name: name.to_s)
      end

      private

      def coerced_name
        @__coerced_name__ ||= coercer[name]
      end
    end

    class Key::Hash < Key
      include Dry.Equalizer(:name, :members, :coercer)

      attr_reader :members

      def initialize(id, members:, **opts)
        super(id, **opts)
        @members = members
      end

      def read(source)
        super if source.is_a?(::Hash)
      end

      def write(source, target)
        read(source) { |value|
          target[coerced_name] = value.is_a?(::Hash) ? members.write(value) : value
        }
      end

      def coercible(&coercer)
        self.class.new(id, name: name, coercer: coercer, members: members.coercible(&coercer))
      end

      def stringified
        self.class.new(id, name: name.to_s, members: members.stringified)
      end
    end

    class Key::Array < Key
      include Dry.Equalizer(:name, :member, :coercer)

      attr_reader :member

      def initialize(id, member:, **opts)
        super(id, **opts)
        @member = member
      end

      def write(source, target)
        read(source) { |value|
          target[coerced_name] = value.is_a?(::Array) ? value.map { |el| member.write(el) } : value
        }
      end

      def coercible(&coercer)
        self.class.new(id, name: name, coercer: coercer, member: member.coercible(&coercer))
      end

      def stringified
        self.class.new(id, name: name.to_s, member: member.stringified)
      end
    end
  end
end