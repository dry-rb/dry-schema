require 'dry/schema/constants'
require 'dry/schema/types'

module Dry
  module Schema
    class TypeRegistry
      attr_reader :types, :namespace

      def self.new(types = Dry::Types, namespace = nil)
        super
      end

      def initialize(types, namespace = nil)
        @types = types
        @namespace = namespace
      end

      def namespaced(ns)
        self.class.new(types, ns)
      end

      def [](name)
        key = [namespace, name].compact.join(DOT)
        type = types.registered?(key) ? types[key] : types[name.to_s]
        type.safe
      end
    end
  end
end