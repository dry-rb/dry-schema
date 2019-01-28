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

      # @!attribute [r] compiler
      #   @return [Compiler] The rule compiler object
      option :compiler, default: -> { Compiler.new }

      # @!attribute [r] processor_type
      #   @return [Compiler] The type of the processor (Params, JSON, or a custom sub-class)
      option :processor_type, default: -> { Processor }

      # @!attribute [r] macros
      #   @return [Array] An array with macros defined within the DSL
      option :macros, default: -> { EMPTY_ARRAY.dup }

      # @!attribute [r] types
      #   @return [Compiler] A key=>type map defined within the DSL
      option :types, default: -> { EMPTY_HASH.dup }

      # @!attribute [r] parent
      #   @return [DSL] An optional parent DSL object that will be used to merge keys and rules
      option :parent, optional: true

      # @!attribute [r] config
      #   @return [Config] Configuration object exposed via `#configure` method
      option :config, optional: true, default: -> { Config.new }

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
      def self.new(options = EMPTY_HASH, &block)
        dsl = super
        dsl.instance_eval(&block) if block
        dsl
      end

      # Provide customized configuration for your schema
      #
      # @example
      #   Dry::Schema.define do
      #     configure do |config|
      #       config.messages = :i18n
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
      def required(name, type = Types::Any, &block)
        key(name, type: type, macro: Macros::Required, &block)
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
      def optional(name, type = Types::Any, &block)
        key(name, type: type, macro: Macros::Optional, &block)
      end

      # A generic method for defining keys
      #
      # @param [Symbol] name The key name
      # @param [Class] macro The macro sub-class (ie `Macros::Required` or any other `Macros::Key` subclass)
      #
      # @return [Macros::Key]
      #
      # @api public
      def key(name, type:, macro:, &block)
        set_type(name, type)

        macro = macro.new(
          name: name,
          compiler: compiler,
          schema_dsl: self,
          filter_schema: filter_schema
        )

        macro.value(&block) if block
        macros << macro
        macro
      end

      # Build a processor based on DSL's definitions
      #
      # @return [Processor]
      #
      # @api private
      def call
        steps = [key_coercer]
        steps << filter_schema.rule_applier if filter_rules?
        steps << value_coercer << rule_applier

        processor_type.new { |processor| steps.each { |step| processor << step } }
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
        -> member_type { Types::Array.of(resolve_type(member_type)) }
      end

      # Return type schema used by the value coercer
      #
      # @return [Dry::Types::Safe]
      #
      # @api private
      def type_schema
        type_registry["hash"].schema(types.merge(parent_types)).safe
      end

      # Return a new DSL instance using the same processor type
      #
      # @return [Dry::Types::Safe]
      #
      # @api private
      def new(&block)
        self.class.new(processor_type: processor_type, &block)
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
        types[name] = resolve_type(spec).meta(omittable: true)
      end

      protected

      # Build a rule applier
      #
      # @return [RuleApplier]
      #
      # @api protected
      def rule_applier
        RuleApplier.new(rules, config: config)
      end

      # Build rules from defined macros
      #
      # @see #rule_applier
      #
      # @api protected
      def rules
        macros.map { |m| [m.name, m.to_rule] }.to_h.merge(parent_rules)
      end

      # Build a key map from defined types
      #
      # @api protected
      def key_map(types = self.types)
        keys = types.keys.each_with_object([]) { |key_name, arr|
          arr << key_spec(key_name, types[key_name])
        }
        km = KeyMap.new(keys)

        if key_map_type
          km.public_send(key_map_type)
        else
          km
        end
      end

      private

      # Check if any filter rules were defined
      #
      # @api private
      def filter_rules?
        instance_variable_defined?('@__filter_schema__') && !filter_schema.macros.empty?
      end

      # Build an input schema DSL used by `filter` API
      #
      # @see Macros::Value#filter
      #
      # @api private
      def filter_schema
        @__filter_schema__ ||= new
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
        processor_type.config.type_registry
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
        if type.hash?
          { name => key_map(type.member_types) }
        elsif type.member_array?
          kv = key_spec(name, type.member)
          kv.equal?(name) ? name : kv.flatten(1)
        else
          name
        end
      end

      # Resolve type object from the provided spec
      #
      # @param [Symbol, Array<Symbol>, Dry::Types::Type]
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
      def parent_rules
        parent&.rules || EMPTY_HASH
      end

      # @api private
      def parent_types
        # TODO: this is awful, it'd be nice if we had `Dry::Types::Hash::Schema#merge`
        parent&.type_schema&.member_types || EMPTY_HASH
      end

      # @api private
      def parent_key_map
        parent&.key_map || EMPTY_ARRAY
      end
    end
  end
end
