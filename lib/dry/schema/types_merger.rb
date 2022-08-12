# frozen_string_literal: true

module Dry
  module Schema
    # Combines multiple logical operations into a single type, taking into
    # account the type of logical operation (or, and, implication) and the
    # underlying types (schemas, nominals, etc.)
    #
    # @api private
    class TypesMerger
      attr_reader :type_registry

      # @api private
      class ValueMerger
        attr_reader :types_merger
        attr_reader :op_class
        attr_reader :old
        attr_reader :new

        # @api private
        def initialize(types_merger, op_class, old, new)
          @types_merger = types_merger
          @op_class = op_class
          @old = old
          @new = new
        end

        # @api private
        def call
          handlers.fetch(op_class).call
        end

        private

        # @api private
        def handlers
          @handlers ||=
            {
              Dry::Logic::Operations::Or => method(:handle_or),
              Dry::Logic::Operations::And => method(:handle_and),
              Dry::Logic::Operations::Implication => method(:handle_implication)
            }
        end

        # @api private
        def handle_or
          old | new
        end

        # @api private
        def handle_ordered
          return old if old == new

          unwrapped_old, old_rule = unwrap_type(old)
          unwrapped_new, new_rule = unwrap_type(new)

          type = merge_underlying_types(unwrapped_old, unwrapped_new)

          rule = [old_rule, new_rule].compact.reduce { op_class.new(_1, _2) }

          type = Dry::Types::Constrained.new(type, rule: rule) if rule

          type
        end

        alias_method :handle_and, :handle_ordered
        alias_method :handle_implication, :handle_ordered

        # @api private
        def merge_underlying_types(unwrapped_old, unwrapped_new)
          case [unwrapped_old, unwrapped_new]
          in Dry::Types::Schema, Dry::Types::Schema
            types_merger.type_registry["hash"].schema(
              types_merger.call(
                op_class,
                unwrapped_old.name_key_map,
                unwrapped_new.name_key_map
              )
            )
          in [Dry::Types::AnyClass, _] | [Dry::Types::Hash, Dry::Types::Schema]
            unwrapped_new
          in [Dry::Types::Hash, Dry::Types::Schema] | [_, Dry::Types::AnyClass]
            unwrapped_old
          else
            if unwrapped_old.primitive != unwrapped_new.primitive
              raise ArgumentError, <<~MESSAGE
                Can't merge types, unwrapped_old=#{unwrapped_old.inspect}, unwrapped_new=#{unwrapped_new.inspect}
              MESSAGE
            end

            unwrapped_old
          end
        end

        # @api private
        def unwrap_type(type)
          rules = []

          while type.is_a?(Dry::Types::Decorator)
            rules << type.rule if type.is_a?(Dry::Types::Constrained)

            if type.meta[:maybe] & type.respond_to?(:right)
              type = type.right
            else
              type = type.type
            end
          end

          [type, rules.reduce(:&)]
        end
      end

      def initialize(type_registry = TypeRegistry.new)
        @type_registry = type_registry
      end

      # @api private
      def call(op_class, lhs, rhs)
        lhs.merge(rhs) do |_k, old, new|
          ValueMerger.new(self, op_class, old, new).call
        end
      end
    end
  end
end
