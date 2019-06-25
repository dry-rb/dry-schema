# frozen_string_literal: true

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
require 'dry/schema/rule_applier'

module Dry
  module Schema
    # The schema definition DSL class
    #
    # The DSL is exposed by:
    #   - `Schema.define`
    #   - `Schema.Params`
    #   - `Schema.JSON`
    #   - `Schema::Params.define` - use with sub-classes
    #   - `Schema::JSON.define` - use with sub-classes
    #
    # @example class-based definition
    #   class UserSchema < Dry::Schema::Params
    #     define do
    #       required(:name).filled
    #       required(:age).filled(:integer, gt: 18)
    #     end
    #   end
    #
    #   user_schema = UserSchema.new
    #   user_schema.(name: 'Jame', age: 21)
    #
    # @example instance-based definition shortcut
    #   UserSchema = Dry::Schema.Params do
    #     required(:name).filled
    #     required(:age).filled(:integer, gt: 18)
    #   end
    #
    #   UserSchema.(name: 'Jame', age: 21)
    #
    # @api public
    class DSL
      Types = Schema::Types

      extend Dry::Initializer

      include ::Dry::Equalizer(:options)

      # @return [Compiler] The rule compiler object
      option :compiler, default: -> { Compiler.new }

      # @return [Compiler] The type of the processor (Params, JSON, or a custom sub-class)
      option :processor_type, default: -> { Processor }

      # @return [Array] An array with macros defined within the DSL
      option :macros, default: -> { EMPTY_ARRAY.dup }

      # @return [Compiler] A key=>type map defined within the DSL
      option :types, default: -> { EMPTY_HASH.dup }

      # @return [DSL] An optional parent DSL object that will be used to merge keys and rules
      option :parent, optional: true

      # @return [Config] Configuration object exposed via `#configure` method
      option :config, optional: true, default: proc { parent ? parent.config.dup : Config.new }

      # Build a new DSL object and evaluate provided block
      #
      # @param [Hash] options
      # @option options [Class] :processor The processor type (`Params`, `JSON` or a custom sub-class)
      # @option options [Compiler] :compiler An instance of a rule compiler (must be compatible with `Schema::Compiler`) (optional)
      # @option options [DSL] :parent An instance of the parent DSL (optional)
      # @option options [Config] :config A configuration object (optional)
      #
      # @see Schema.define
      # @see Schema.Params
      # @see Schema.JSON
      # @see Processor.define
      #
      # @return [DSL]
      #
      # @api public
      def self.new(**options, &block)
        dsl = super
        dsl.instance_eval(&block) if block
        dsl
      end

      # Provide customized configuration for your schema
      #
      # @example
      #   Dry::Schema.define do
      #     configure do |config|
      #       config.messages.backend = :i18n
      #     end
      #   end
      #
      # @see Config
      #
      # @return [DSL]
      #
      # @api public
      def configure(&block)
        config.configure(&block)
        self
      end

      # Return a macro with the provided name
      #
      # @param [Symbol] name
      #
      # @return [Macros::Core]
      #
      # @api public
      def [](name)
        macros.detect { |macro| macro.name.equal?(name) }
      end

      # Define a required key
      #
      # @example
      #   required(:name).filled
      #
      #   required(:age).value(:integer)
      #
      #   required(:user_limit).value(:integer, gt?: 0)
      #
      #   required(:tags).filled { array? | str? }
      #
      # @param [Symbol] name The key name
      #
      # @return [Macros::Required]
      #
      # @api public
      def required(name, &block)
        key(name, macro: Macros::Required, &block)
      end

      # Define an optional key
      #
      # This works exactly the same as `required` except that if a key is not present
      # rules will not be applied
      #
      # @see DSL#required
      #
      # @param [Symbol] name The key name
      #
      # @return [Macros::Optional]
      #
      # @api public
      def optional(name, &block)
        key(name, macro: Macros::Optional, &block)
      end

      # A generic method for defining keys
      #
      # @param [Symbol] name The key name
      # @param [Class] macro The macro sub-class (ie `Macros::Required` or any other `Macros::Key` subclass)
      #
      # @return [Macros::Key]
      #
      # @api public
      def key(name, macro:, &block)
        raise ArgumentError, "Key +#{name}+ is not a symbol" unless name.is_a?(::Symbol)

        set_type(name, Types::Any)

        macro = macro.new(
          name: name,
          compiler: compiler,
          schema_dsl: self,
          filter_schema_dsl: filter_schema_dsl
        )

        macro.value(&block) if block
        macros << macro
        macro
      end

      # Build a processor based on DSL's definitions
      #
      # @return [Processor, Params, JSON]
      #
      # @api private
      def call
        steps = [key_coercer]
        steps << filter_schema.rule_applier if filter_rules?
        steps << value_coercer << rule_applier

        processor_type.new(schema_dsl: self, steps: steps)
      end

      # Cast this DSL into a rule object
      #
      # @return [RuleApplier]
      def to_rule
        call.to_rule
      end

      # A shortcut for defining an array type with a member
      #
      # @example
      #   required(:tags).filled(array[:string])
      #
      # @return [Dry::Types::Array::Member]
      #
      # @api public
      def array
        -> member_type { type_registry['array'].of(resolve_type(member_type)) }
      end

      # Return type schema used by the value coercer
      #
      # @return [Dry::Types::Safe]
      #
      # @api private
      def type_schema
        schema = type_registry['hash'].schema(types).lax
        parent ? parent.type_schema.schema(schema.to_a) : schema
      end

      # Return a new DSL instance using the same processor type
      #
      # @return [Dry::Types::Safe]
      #
      # @api private
      def new(options = EMPTY_HASH, &block)
        self.class.new(options.merge(processor_type: processor_type, config: config), &block)
      end

      # Set a type for the given key name
      #
      # @param [Symbol] name The key name
      # @param [Symbol, Array<Symbol>, Dry::Types::Type] spec The type spec or a type object
      #
      # @return [Dry::Types::Safe]
      #
      # @api private
      def set_type(name, spec)
        type = resolve_type(spec)
        meta = { required: false, maybe: type.optional? }

        types[name] = type.meta(meta)
      end

      # Resolve type object from the provided spec
      #
      # @param [Symbol, Array<Symbol>, Dry::Types::Type] spec
      #
      # @return [Dry::Types::Type]
      #
      # @api private
      def resolve_type(spec)
        case spec
        when ::Dry::Types::Type then spec
        when ::Array then spec.map { |s| resolve_type(s) }.reduce(:|)
        else
          type_registry[spec]
        end
      end

      # @api private
      def filter_schema
        filter_schema_dsl.call
      end

      # Build an input schema DSL used by `filter` API
      #
      # @see Macros::Value#filter
      #
      # @api private
      def filter_schema_dsl
        @filter_schema_dsl ||= new(parent: parent_filter_schema)
      end

      # Check if any filter rules were defined
      #
      # @api private
      def filter_rules?
        (instance_variable_defined?('@filter_schema_dsl') && !filter_schema_dsl.macros.empty?) || parent&.filter_rules?
      end

      protected

      # Build a rule applier
      #
      # @return [RuleApplier]
      #
      # @api protected
      def rule_applier
        RuleApplier.new(rules, config: config.finalize!)
      end

      # Build rules from defined macros
      #
      # @see #rule_applier
      #
      # @api protected
      def rules
        parent_rules.merge(macros.map { |m| [m.name, m.to_rule] }.to_h.compact)
      end

      # Build a key map from defined types
      #
      # @api protected
      def key_map(types = self.types)
        keys = types.map { |key, type| key_spec(key, type) }
        km = KeyMap.new(keys)

        if key_map_type
          km.public_send(key_map_type)
        else
          km
        end
      end

      private

      # @api private
      def parent_filter_schema
        return unless parent

        parent.filter_schema if parent.filter_rules?
      end

      # Build a key coercer
      #
      # @return [KeyCoercer]
      #
      # @api private
      def key_coercer
        KeyCoercer.symbolized(key_map + parent_key_map)
      end

      # Build a value coercer
      #
      # @return [ValueCoercer]
      #
      # @api private
      def value_coercer
        ValueCoercer.new(type_schema)
      end

      # Return type registry configured by the processor type
      #
      # @api private
      def type_registry
        @type_registry ||= TypeRegistry.new(
          config.types,
          processor_type.config.type_registry_namespace
        )
      end

      # Return key map type configured by the processor type
      #
      # @api private
      def key_map_type
        processor_type.config.key_map_type
      end

      # Build a key spec needed by the key map
      #
      # @api private
      def key_spec(name, type)
        if type.respond_to?(:keys)
          { name => key_map(type.name_key_map) }
        elsif type.respond_to?(:member)
          kv = key_spec(name, type.member)
          kv.equal?(name) ? name : kv.flatten(1)
        else
          name
        end
      end

      # @api private
      def parent_rules
        parent&.rules || EMPTY_HASH
      end

      # @api private
      def parent_key_map
        parent&.key_map || EMPTY_ARRAY
      end
    end
  end
end
