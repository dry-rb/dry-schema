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
        option :filter_schema, optional: true, default: proc { schema_dsl&.new }

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
          extract_type_spec(*args) do |*predicates|
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
          extract_type_spec(*args) do |*predicates|
            super(*predicates, **opts, &block)
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
          extract_type_spec(*args, nullable: true) do |*predicates|
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

          if type_spec.kind_of?(Schema::Processor) || type_spec.is_a?(Symbol) && type_spec.to_s.end_with?(QUESTION_MARK)
            type_spec = nil
          end

          predicates = Array(type_spec ? args[1..-1] : args)

          if type_spec
            type(nullable && !type_spec.is_a?(::Array) ? [:nil, type_spec] : type_spec)
            type_predicate = PredicateInferrer[schema_dsl.types[name]]

            unless predicates.include?(type_predicate)
              if compiler.supports?(type_predicate)
                predicates.unshift(type_predicate)
              else
                raise ArgumentError, "Cannot infer type-check predicate from +#{type_spec.inspect}+ type spec"
              end
            end
          end

          yield(*predicates)
        end
      end
    end
  end
end
