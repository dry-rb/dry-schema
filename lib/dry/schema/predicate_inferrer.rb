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
        TrueClass => :true?
      }.freeze

      REDUCED_TYPES = {
        %i[true? false?] => :bool?
      }.freeze

      # Compiler reduces type AST into a list of predicates
      #
      # @api private
      class Compiler
        def visit(node)
          meth, rest = node
          public_send(:"visit_#{meth}", rest)
        end

        def visit_nominal(node)
          type = node[0]

          TYPE_TO_PREDICATE.fetch(type) {
            :"#{type.name.split('::').last.downcase}?"
          }
        end

        def visit_hash(_)
          :hash?
        end

        def visit_array(_)
          :array?
        end

        def visit_safe(node)
          other, * = node
          visit(other)
        end

        def visit_constructor(node)
          other, * = node
          visit(other)
        end

        def visit_enum(node)
          other, * = node
          visit(other)
        end

        def visit_sum(node)
          left, right = node

          predicates = [visit(left), visit(right)]

          if predicates.first == :nil?
            predicates[1..predicates.size - 1]
          else
            predicates
          end
        end

        def visit_constrained(node)
          other, * = node
          visit(other)
        end
      end

      # Infer predicate identifier from the provided type
      #
      # @return [Symbol]
      #
      # @api private
      def self.[](type)
        fetch_or_store(type.hash) {
          predicates = Array(compiler.visit(type.to_ast)).flatten
          Array(REDUCED_TYPES[predicates] || predicates).flatten
        }
      end

      # @api private
      def self.compiler
        @compiler ||= Compiler.new
      end
    end
  end
end
