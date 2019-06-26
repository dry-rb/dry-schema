# frozen_string_literal: true

require 'dry/logic/operators'

require 'dry/schema/macros/core'

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

        # @overload value(*predicates, **predicate_opts)
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
        def value(*predicates, **opts, &block)
          append_macro(Macros::Value) do |macro|
            macro.call(*predicates, **opts, &block)
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
        def filled(*args, **opts, &block)
          append_macro(Macros::Filled) do |macro|
            macro.call(*args, **opts, &block)
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
        def schema(*args, &block)
          append_macro(Macros::Schema) do |macro|
            macro.call(*args, &block)
          end
        end

        # Specify a nested hash with enforced `hash?` type-check
        #
        # @example
        #   required(:tags).hash do
        #     required(:name).value(:string)
        #   end
        #
        # @api public
        def hash(*args, &block)
          append_macro(Macros::Hash) do |macro|
            macro.call(*args, &block)
          end
        end

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
        def each(*args, &block)
          append_macro(Macros::Each) do |macro|
            macro.value(*args, &block)
          end
        end

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
        def array(*args, &block)
          append_macro(Macros::Array) do |macro|
            macro.value(*args, &block)
          end
        end

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
        def type(spec)
          schema_dsl.set_type(name, spec)
          self
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
        def extract_type_spec(*args, nullable: false, set_type: true)
          type_spec = args[0]

          is_type_spec = type_spec.is_a?(Dry::Schema::Processor) ||
                         type_spec.is_a?(Symbol) &&
                         type_spec.to_s.end_with?(QUESTION_MARK)

          type_spec = nil if is_type_spec

          predicates = Array(type_spec ? args[1..-1] : args)

          if type_spec
            resolved_type = schema_dsl.resolve_type(
              nullable && !type_spec.is_a?(::Array) ? [:nil, type_spec] : type_spec
            )

            type(resolved_type) if set_type

            type_predicates = predicate_inferrer[resolved_type]

            predicates.replace(type_predicates + predicates) unless type_predicates.empty?

            return self if predicates.empty?
          end

          yield(*predicates, type_spec: type_spec)
        end
      end
    end
  end
end
