require 'dry/schema/macros/core'
require 'dry/schema/macros/value'
require 'dry/schema/macros/each'
require 'dry/schema/macros/maybe'

module Dry
  module Schema
    module Macros
      class Key < Core
        def maybe(*args, **opts, &block)
          if args.include?(:empty?)
            raise ::Dry::Schema::InvalidSchemaError, "Using maybe with empty? predicate is invalid"
          end

          if args.include?(:none?)
            raise ::Dry::Schema::InvalidSchemaError, "Using maybe with none? predicate is redundant"
          end

          macro = Maybe.new
          macro.value(*args, **opts, &block)
          trace << macro
          self
        end

        def to_rule
          if trace.nodes.empty?
            super
          else
            [super, trace.to_rule(name)].reduce(operation)
          end
        end

        def to_ast
          [:predicate, [:key?, [[:name, name], [:input, Undefined]]]]
        end
      end
    end
  end
end
