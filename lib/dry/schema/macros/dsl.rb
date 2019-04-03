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

        # @api private
        option :chain, default: -> { true }

        # @!attribute [r] predicate_inferrer
        #   @return [PredicateInferrer]
        #   @api private
        option :predicate_inferrer, default: proc { PredicateInferrer.new(compiler.predicates) }

        # Specify predicates that should be applied to a value
        #
        # @api public
        def value(*predicates, **opts, &block)
          append_macro(Macros::Value) do |macro|
            macro.call(*predicates, **opts, &block)
          end
        end

        # Prepends `:filled?` predicate
        #
        # @api public
        def filled(*args, &block)
          append_macro(Macros::Filled) do |macro|
            macro.call(*args, &block)
          end
        end

        # Specify a nested hash without enforced hash? type-check
        #
        # @api public
        def schema(*args, &block)
          append_macro(Macros::Schema) do |macro|
            macro.call(*args, &block)
          end
        end

        # Specify a nested hash with enforced hash? type-check
        #
        # @see #schema
        #
        # @api public
        def hash(*args, &block)
          append_macro(Macros::Hash) do |macro|
            macro.call(*args, &block)
          end
        end

        # Specify predicates that should be applied to each element of an array
        #
        # @api public
        def each(*args, &block)
          append_macro(Macros::Each) do |macro|
            macro.value(*args, &block)
          end
        end

        # Like `each`, but prepends `array?` check
        #
        # @api public
        def array(*args, &block)
          append_macro(Macros::Array) do |macro|
            macro.value(*args, &block)
          end
        end

        # Set type spec
        #
        # @param [Symbol, Array, Dry::Types::Type]
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

          is_type_spec = type_spec.kind_of?(Dry::Schema::Processor) ||
                         type_spec.is_a?(Symbol) &&
                         type_spec.to_s.end_with?(QUESTION_MARK)

          type_spec = nil if is_type_spec

          predicates = Array(type_spec ? args[1..-1] : args)

          if type_spec
            type(nullable && !type_spec.is_a?(::Array) ? [:nil, type_spec] : type_spec) if set_type

            type_predicates = predicate_inferrer[schema_dsl.types[name]]

            unless predicates.include?(type_predicates)
              if type_predicates.is_a?(::Array) && type_predicates.size.equal?(1)
                predicates.unshift(type_predicates[0])
              else
                predicates.unshift(type_predicates)
              end
            end
          end

          yield(*predicates, type_spec: type_spec)
        end
      end
    end
  end
end
