require 'dry/initializer'

require 'dry/schema/constants'
require 'dry/schema/compiler'
require 'dry/schema/definition'
require 'dry/schema/types'
require 'dry/schema/macros'

module Dry
  module Schema
    class DSL
      Types = Schema::Types

      extend Dry::Initializer

      include ::Dry::Equalizer(:options)

      option :compiler, default: -> { Compiler.new }

      option :macros, default: -> { EMPTY_ARRAY.dup }

      option :types, default: -> { EMPTY_HASH.dup }

      option :type_registry, default: -> { -> name { ::Dry::Types[name.to_s] } }

      option :hash_type, default: -> { :schema }

      option :parent, optional: true

      def self.new(options = EMPTY_HASH, &block)
        dsl = super
        dsl.instance_eval(&block) if block
        dsl
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

      def call
        Definition.new(rules, type_schema: type_schema)
      end

      def to_rule
        call.to_rule
      end

      def array
        -> member_type { Types::Array.of(resolve_type(member_type)) }
      end

      def type_schema
        type_registry["hash"].public_send(hash_type, types.merge(parent_types)).safe
      end

      def new(&block)
        self.class.new(type_registry: type_registry, hash_type: hash_type, &block)
      end

      private

      def set_type(name, spec)
        types[name] = resolve_type(spec).meta(omittable: true)
      end

      def resolve_type(spec)
        case spec
        when ::Dry::Types::Type then spec
        when ::Array then spec.map { |s| resolve_type(s) }.reduce(:|)
        else
          type_registry[spec]
        end
      end

      def rules
        macros.map { |m| [m.name, m.to_rule] }.to_h.merge(parent_rules)
      end

      def parent_rules
        parent&.rules || EMPTY_HASH
      end

      def parent_types
        # TODO: this is awful, it'd be nice if we had `Dry::Types::Hash::Schema#merge`
        parent&.type_schema&.member_types || EMPTY_HASH
      end
    end
  end
end
