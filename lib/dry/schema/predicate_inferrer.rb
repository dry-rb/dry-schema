# frozen_string_literal: true

require 'dry/core/cache'

module Dry
  module Schema
    # PredicateInferrer is used internally by `Macros::Value`
    # for inferring type-check predicates from type specs.
    #
    # @api private
    class PredicateInferrer
      extend Dry::Core::Cache

      TYPE_TO_PREDICATE = {
        DateTime => :date_time?,
        FalseClass => :false?,
        Integer => :int?,
        NilClass => :nil?,
        String => :str?,
        TrueClass => :true?,
        BigDecimal => :decimal?
      }.freeze

      REDUCED_TYPES = {
        %i[true? false?] => :bool?
      }.freeze

      # Compiler reduces type AST into a list of predicates
      #
      # @api private
      class Compiler
        # @return [PredicateRegistry]
        # @api private
        attr_reader :registry

        # @api private
        def initialize(registry)
          @registry = registry
        end

        # @api private
        def infer_predicate(type)
          TYPE_TO_PREDICATE.fetch(type) { :"#{type.name.split('::').last.downcase}?" }
        end

        # @api private
        def visit(node)
          meth, rest = node
          public_send(:"visit_#{meth}", rest)
        end

        # @api private
        def visit_nominal(node)
          type = node[0]
          predicate = infer_predicate(type)

          if registry.key?(predicate)
            predicate
          else
            { type?: type }
          end
        end

        # @api private
        def visit_hash(_)
          :hash?
        end

        # @api private
        def visit_array(_)
          :array?
        end

        # @api private
        def visit_lax(node)
          visit(node)
        end

        # @api private
        def visit_constructor(node)
          other, * = node
          visit(other)
        end

        # @api private
        def visit_enum(node)
          other, * = node
          visit(other)
        end

        # @api private
        def visit_sum(node)
          left, right = node

          predicates = [visit(left), visit(right)]

          if predicates.first == :nil?
            predicates[1..predicates.size - 1]
          else
            predicates
          end
        end

        # @api private
        def visit_constrained(node)
          other, * = node
          visit(other)
        end

        # @api private
        def visit_any(_)
          nil
        end
      end

      # @return [Compiler]
      # @api private
      attr_reader :compiler

      # @api private
      def initialize(registry)
        @compiler = Compiler.new(registry)
      end

      # Infer predicate identifier from the provided type
      #
      # @return [Symbol]
      #
      # @api private
      def [](type)
        self.class.fetch_or_store(type.hash) do
          predicates = compiler.visit(type.to_ast)

          if predicates.is_a?(Hash)
            predicates
          else
            Array(REDUCED_TYPES[predicates] || predicates).flatten
          end
        end
      end
    end
  end
end
