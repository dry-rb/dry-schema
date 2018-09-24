require 'dry/schema/types'
require 'dry/schema/macros'

module Dry
  module Schema
    class DSL < BasicObject
      Types = ::Dry::Schema::Types

      include ::Dry::Equalizer(:compiler, :options)

      attr_reader :compiler

      attr_reader :macros

      attr_reader :types

      attr_reader :type_registry

      attr_reader :hash_type

      attr_reader :options

      def initialize(compiler, options = {}, &block)
        @compiler = compiler
        @options = options
        @macros = []
        @types = {}
        @hash_type = options.fetch(:hash_type, :schema)
        @type_registry = options.fetch(:type_registry, -> name { ::Dry::Types[name.to_s] })
        instance_eval(&block) if block
      end

      def array
        -> member_type { Types::Array.of(resolve_type(member_type)) }
      end

      def class
        ::Dry::Schema::DSL
      end

      def call
        macros.map { |m| [m.name, m.to_rule] }.to_h.merge(parent_rules)
      end

      def type_schema
        type_registry["hash"].public_send(hash_type, types.merge(parent_types))
      end

      def required(name, type = Types::Any, &block)
        key(name, type: type, macro: Macros::Required, &block)
      end

      def optional(name, type = Types::Any, &block)
        key(name, type: type, macro: Macros::Optional, &block)
      end

      def key(name, type:, macro:, &block)
        set_type(name, type)

        macro = macro.new(name: name, compiler: compiler, schema_dsl: self)
        macro.value(&block) if block
        macros << macro
        macro
      end

      def new(&block)
        self.class.new(compiler, options, &block)
      end

      private

      def set_type(name, spec)
        types[name] = resolve_type(spec)
      end

      def resolve_type(spec)
        case spec
        when ::Dry::Types::Type then spec
        when ::Array then spec.map { |s| resolve_type(s) }.reduce(:|)
        else
          type_registry[spec]
        end
      end

      def parent_rules
        options[:parent]&.rules || {}
      end

      def parent_types
        # TODO: this is awful, it'd be nice if we had `Dry::Types::Hash::Schema#merge`
        options[:parent]&.type_schema&.member_types || {}
      end
    end
  end
end
