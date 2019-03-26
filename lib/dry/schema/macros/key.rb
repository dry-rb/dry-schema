# frozen_string_literal: true

require 'dry/schema/predicate_inferrer'
require 'dry/schema/processor'
require 'dry/schema/macros/dsl'
require 'dry/schema/constants'

module Dry
  module Schema
    module Macros
      # Base macro for specifying rules applied to a value found under the key
      #
      # @see DSL#key
      #
      # @api public
      class Key < DSL
        # @!attribute [r] filter_schema
        #   @return [Schema::DSL]
        #   @api private
        option :filter_schema, optional: true, default: proc { schema_dsl&.new }

        # @!attribute [r] predicate_inferrer
        #   @return [PredicateInferrer]
        #   @api private
        option :predicate_inferrer, default: proc {
          PredicateInferrer.new(compiler.predicates)
        }

        # Specify predicates that should be used to filter out values
        # before coercion is applied
        #
        # @see Macros::DSL#value
        #
        # @return [Macros::Key]
        #
        # @api public
        def filter(*args, &block)
          filter_schema.optional(name).value(*args, &block)
          self
        end

        # Set type specification and predicates
        #
        # @see Macros::DSL#value
        #
        # @return [Macros::Key]
        #
        # @api public
        def value(*args, **opts, &block)
          extract_type_spec(*args) do |*predicates, type_spec:|
            super(*predicates, **opts, &block)
          end
        end

        # Set type specification and predicates for a filled value
        #
        # @see Macros::DSL#value
        #
        # @return [Macros::Key]
        #
        # @api public
        def filled(*args, **opts, &block)
          extract_type_spec(*args) do |*predicates, type_spec:|
            super(*predicates, type_spec: type_spec, **opts, &block)
          end
        end

        # Set type specification and predicates for a maybe value
        #
        # @see Macros::DSL#value
        #
        # @return [Macros::Key]
        #
        # @api public
        def maybe(*args, **opts, &block)
          extract_type_spec(*args, nullable: true) do |*predicates, type_spec:|
            append_macro(Macros::Maybe) do |macro|
              macro.call(*predicates, **opts, &block)
            end
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

        # Coerce macro to a rule
        #
        # @return [Dry::Logic::Rule]
        #
        # @api private
        def to_rule
          if trace.captures.empty?
            super
          else
            [super, trace.to_rule(name)].reduce(operation)
          end
        end

        # @api private
        def to_ast
          [:predicate, [:key?, [[:name, name], [:input, Undefined]]]]
        end

        private

        # @api private
        def extract_type_spec(*args, nullable: false)
          type_spec = args[0]

          is_type_spec = type_spec.kind_of?(Dry::Schema::Processor) ||
                         type_spec.is_a?(Symbol) &&
                         type_spec.to_s.end_with?(QUESTION_MARK)

          type_spec = nil if is_type_spec

          predicates = Array(type_spec ? args[1..-1] : args)

          if type_spec
            type(nullable && !type_spec.is_a?(::Array) ? [:nil, type_spec] : type_spec)

            type_predicates = predicate_inferrer[schema_dsl.types[name]]

            unless predicates.include?(type_predicates)
              if type_predicates.is_a?(::Array) && type_predicates.size.equal?(1)
                predicates.unshift(type_predicates[0])
              else
                predicates.unshift(type_predicates)
              end
            end
          end

          yield(*predicates, type_spec: !type_spec.nil?)
        end
      end
    end
  end
end
