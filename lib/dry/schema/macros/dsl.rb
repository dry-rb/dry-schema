# frozen_string_literal: true

require "dry/logic/operators"

require "dry/schema/macros/core"
require "dry/schema/predicate_inferrer"
require "dry/schema/primitive_inferrer"

module Dry
  module Schema
    module Macros
      # Macro specialization used within the DSL
      #
      # @api public
      class DSL < Core
        include Dry::Logic::Operators

        undef :eql?
        undef :nil?
        undef :respond_to?

        # @!attribute [r] chain
        #   Indicate if the macro should append its rules to the provided trace
        #   @return [Boolean]
        #   @api private
        option :chain, default: -> { true }

        # @!attribute [r] predicate_inferrer
        #   PredicateInferrer is used to infer predicate type-check from a type spec
        #   @return [PredicateInferrer]
        #   @api private
        option :predicate_inferrer, default: proc { PredicateInferrer.new(compiler.predicates) }

        # @!attribute [r] primitive_inferrer
        #   PrimitiveInferrer used to get a list of primitive classes from configured type
        #   @return [PrimitiveInferrer]
        #   @api private
        option :primitive_inferrer, default: proc { PrimitiveInferrer.new }

        # @overload value(type_spec, *predicates, **predicate_opts)
        #   Set predicates without and with arguments
        #
        #   @param [Array<Symbol>] predicates
        #   @param [Hash] predicate_opts
        #
        #   @example with a predicate
        #     required(:name).value(:filled?)
        #
        #   @example with a predicate with arguments
        #     required(:name).value(min_size?: 2)
        #
        #   @example with a predicate with and without arguments
        #     required(:name).value(:filled?, min_size?: 2)
        #
        #   @example with a block
        #     required(:name).value { filled? & min_size?(2) }
        #
        # @return [Macros::Core]
        #
        # @api public
        def value(type_spec, ...)
          append_macro(Macros::Value) do |macro|
            macro.call(type_spec, ...)
          end
        end

        # Prepends `:filled?` predicate
        #
        # @example with a type spec
        #   required(:name).filled(:string)
        #
        # @example with a type spec and a predicate
        #   required(:name).filled(:string, format?: /\w+/)
        #
        # @return [Macros::Core]
        #
        # @api public
        def filled(type_spec, ...)
          append_macro(Macros::Filled) do |macro|
            macro.call(type_spec, ...)
          end
        end

        # Set type specification and predicates for a maybe value
        #
        # @example
        #   required(:name).maybe(:string)
        #
        # @see Macros::Key#value
        #
        # @return [Macros::Key]
        #
        # @api public
        def maybe(type_spec, ...)
          append_macro(Macros::Maybe) do |macro|
            macro.call(type_spec, ...)
          end
        end

        # Specify a nested hash without enforced `hash?` type-check
        #
        # This is a simpler building block than `hash` macro, use it
        # when you want to provide `hash?` type-check with other rules
        # manually.
        #
        # @example
        #   required(:tags).value(:hash, min_size?: 1).schema do
        #     required(:name).value(:string)
        #   end
        #
        # @return [Macros::Core]
        #
        # @api public
        def schema(...)
          append_macro(Macros::Schema) do |macro|
            macro.call(...)
          end
        end
        ruby2_keywords :schema if respond_to?(:ruby2_keywords, true)

        # Specify a nested hash with enforced `hash?` type-check
        #
        # @example
        #   required(:tags).hash do
        #     required(:name).value(:string)
        #   end
        #
        # @api public
        def hash(...)
          append_macro(Macros::Hash) do |macro|
            macro.call(...)
          end
        end
        ruby2_keywords :hash if respond_to?(:ruby2_keywords, true)

        # Specify predicates that should be applied to each element of an array
        #
        # This is a simpler building block than `array` macro, use it
        # when you want to provide `array?` type-check with other rules
        # manually.
        #
        # @example a list of strings
        #   required(:tags).value(:array, min_size?: 2).each(:str?)
        #
        # @example a list of hashes
        #   required(:tags).value(:array, min_size?: 2).each(:hash) do
        #     required(:name).filled(:string)
        #   end
        #
        # @return [Macros::Core]
        #
        # @api public
        def each(...)
          append_macro(Macros::Each) do |macro|
            macro.value(...)
          end
        end
        ruby2_keywords :each if respond_to?(:ruby2_keywords, true)

        # Like `each` but sets `array?` type-check
        #
        # @example a list of strings
        #   required(:tags).array(:str?)
        #
        # @example a list of hashes
        #   required(:tags).array(:hash) do
        #     required(:name).filled(:string)
        #   end
        #
        # @return [Macros::Core]
        #
        # @api public
        def array(...)
          append_macro(Macros::Array) do |macro|
            macro.value(...)
          end
        end
        ruby2_keywords :array if respond_to?(:ruby2_keywords, true)

        # Set type spec
        #
        # @example
        #   required(:name).type(:string).value(min_size?: 2)
        #
        # @param [Symbol, Array, Dry::Types::Type] spec
        #
        # @return [Macros::Key]
        #
        # @api public
        def type(type)
          schema_dsl.set_type(name, type)
          self
        end
        alias_method :set_type, :type

        # @api private
        def custom_type?
          schema_dsl.custom_type?(name)
        end

        private

        # @api private
        def append_macro(macro_type)
          macro = macro_type.new(schema_dsl: schema_dsl, name: name)

          yield(macro)

          if chain
            trace << macro
            self
          else
            macro
          end
        end

        # @api private
        def resolve_type(type_spec, nullable: false)
          resolved = schema_dsl.resolve_type(type_spec)

          if type_spec.is_a?(::Array) || !nullable || resolved.optional?
            resolved
          else
            schema_dsl.resolve_type([:nil, resolved])
          end
        end
      end
    end
  end
end
