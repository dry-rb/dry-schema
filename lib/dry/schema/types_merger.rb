# frozen_string_literal: true

require "dry/logic"
require "dry/types"

require "dry/schema/type_registry"

module Dry
  module Schema
    # @api private
    class TypesMerger
      attr_reader :type_registry

      def initialize(type_registry = TypeRegistry.new)
        @type_registry = type_registry
      end

      # @api private
      def call(op_class, lhs, rhs)
        fn = handlers.fetch(op_class)
        lhs.merge(rhs) { |_k, lhs, rhs| fn.(op_class, lhs, rhs) }
      end

      private

      # @api private
      def handlers
        @handlers ||= {
          Dry::Logic::Operations::Or => method(:handle_or),
          Dry::Logic::Operations::And => method(:handle_and),
          Dry::Logic::Operations::Implication => method(:handle_and)
        }
      end

      # @api private
      def handle_or(_op_class, lhs, rhs)
        lhs | rhs
      end

      # @api private
      def handle_and(op_class, lhs, rhs)
        return lhs if lhs == rhs

        lhs, lhs_rule = unwrap_type(lhs)
        rhs, rhs_rule = unwrap_type(rhs)

        type = merge_underlying_types(op_class, lhs, rhs)

        rule = [lhs_rule, rhs_rule].compact.reduce { op_class.new(_1, _2) }

        type = Dry::Types::Constrained.new(type, rule: rule) if rule

        type
      end

      # @api private
      # rubocop:disable Metrics/PerceivedComplexity
      def merge_underlying_types(op_class, lhs, rhs)
        if lhs.is_a?(Dry::Types::Schema) && rhs.is_a?(Dry::Types::Schema)
          type_registry["hash"].schema(
            call(op_class, lhs.name_key_map, rhs.name_key_map)
          )
        elsif lhs.is_a?(Dry::Types::AnyClass) ||
              (lhs.is_a?(Dry::Types::Hash) && rhs.is_a?(Dry::Types::Schema))
          rhs
        elsif rhs.is_a?(Dry::Types::AnyClass) ||
              (lhs.is_a?(Dry::Types::Schema) && rhs.is_a?(Dry::Types::Hash))
          lhs
        elsif lhs.primitive == rhs.primitive
          lhs
        else
          raise ArgumentError,
                "Can't merge types, lhs=#{lhs.inspect}, rhs=#{rhs.inspect}"
        end
      end
      # rubocop:enable Metrics/PerceivedComplexity

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
  end
end
