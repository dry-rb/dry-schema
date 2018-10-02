require 'dry/schema/macros/dsl'

module Dry
  module Schema
    module Macros
      class Maybe < DSL
        def call(*args, **opts, &block)
          if args.include?(:empty?)
            raise ::Dry::Schema::InvalidSchemaError, "Using maybe with empty? predicate is invalid"
          end

          if args.include?(:none?)
            raise ::Dry::Schema::InvalidSchemaError, "Using maybe with none? predicate is redundant"
          end

          value(*args, **opts, &block)

          self
        end

        def to_ast
          [:implication,
           [
             [:not, [:predicate, [:none?, [[:input, Undefined]]]]],
             trace.to_rule.to_ast
           ]
          ]
        end
      end
    end
  end
end
