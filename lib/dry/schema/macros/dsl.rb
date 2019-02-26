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
          value(:array)
          append_macro(Macros::Each) do |macro|
            macro.value(*args, &block)
          end
        end

        private

        # @api private
        def append_macro(macro_type, &block)
          macro = macro_type.new(schema_dsl: schema_dsl, name: name)

          yield(macro)

          if chain
            trace << macro
            self
          else
            macro
          end
        end
      end
    end
  end
end
