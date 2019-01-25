require 'dry/initializer'

require 'dry/schema/constants'
require 'dry/schema/config'
require 'dry/schema/compiler'
require 'dry/schema/types'
require 'dry/schema/macros'

require 'dry/schema/processor'
require 'dry/schema/key_map'
require 'dry/schema/key_coercer'
require 'dry/schema/value_coercer'
require 'dry/schema/definition'

module Dry
  module Schema
    class DSL
      Types = Schema::Types

      extend Dry::Initializer

      include ::Dry::Equalizer(:options)

      option :compiler, default: -> { Compiler.new }

      option :processor_type, default: -> { Processor }

      option :macros, default: -> { EMPTY_ARRAY.dup }

      option :types, default: -> { EMPTY_HASH.dup }

      option :parent, optional: true

      option :config, optional: true, default: -> { Config.new }

      def self.new(options = EMPTY_HASH, &block)
        dsl = super
        dsl.instance_eval(&block) if block
        dsl
      end

      def configure(&block)
        config.configure(&block)
        self
      end

      def required(name, type = Types::Any, &block)
        key(name, type: type, macro: Macros::Required, &block)
      end

      def optional(name, type = Types::Any, &block)
        key(name, type: type, macro: Macros::Optional, &block)
      end

      def key(name, type:, macro:, &block)
        set_type(name, type)

        macro = macro.new(
          name: name,
          compiler: compiler,
          schema_dsl: self,
          input_schema: input_schema
        )

        macro.value(&block) if block
        macros << macro
        macro
      end

      def call
        steps = [key_coercer]
        steps << input_schema.definition unless input_schema.macros.empty?
        steps << value_coercer << definition

        processor_type.new { |processor| steps.each { |step| processor << step } }
      end

      def key_coercer
        KeyCoercer.symbolized(key_map + parent_key_map)
      end

      def value_coercer
        ValueCoercer.new(type_schema)
      end

      def definition
        Definition.new(rules, config: config)
      end

      def to_rule
        call.to_rule
      end

      def array
        -> member_type { Types::Array.of(resolve_type(member_type)) }
      end

      def type_schema
        type_registry["hash"].schema(types.merge(parent_types)).safe
      end

      def new(&block)
        self.class.new(processor_type: processor_type, &block)
      end

      def set_type(name, spec)
        types[name] = resolve_type(spec).meta(omittable: true)
      end

      protected

      def rules
        macros.map { |m| [m.name, m.to_rule] }.to_h.merge(parent_rules)
      end

      private

      def type_registry
        processor_type.config.type_registry
      end

      def key_map_type
        processor_type.config.key_map_type
      end

      def input_schema
        @__input_schema__ ||= new
      end

      def key_map(types = self.types)
        keys = types.keys.each_with_object([]) { |key_name, arr|
          arr << key_value(key_name, types[key_name])
        }
        km = KeyMap.new(keys)

        if key_map_type
          km.public_send(key_map_type)
        else
          km
        end
      end

      def key_value(name, type)
        if type.hash?
          { name => key_map(type.member_types) }
        elsif type.member_array?
          kv = key_value(name, type.member)
          kv === name ? name : kv.flatten(1)
        else
          name
        end
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
        parent&.rules || EMPTY_HASH
      end

      def parent_types
        # TODO: this is awful, it'd be nice if we had `Dry::Types::Hash::Schema#merge`
        parent&.type_schema&.member_types || EMPTY_HASH
      end

      def parent_key_map
        parent&.key_map || EMPTY_ARRAY
      end
    end
  end
end
