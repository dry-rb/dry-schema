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
      end
    end
  end
end
