require 'dry/schema/constants'

module Dry
  module Schema
    module OpenAPI
      class SchemaCompiler
        attr_reader :properties

        PREDICATE_TO_TYPE = {
          str?: "string", int?: "integer"
        }

        def initialize
          @properties = {}
        end

        def to_h
          { properties: properties }
        end

        def call(ast)
          visit(ast)
        end

        def visit(node, opts = EMPTY_HASH)
          meth, rest = node
          public_send(:"visit_#{meth}", rest, opts)
        end

        def visit_set(node, opts = EMPTY_HASH)
          node.map { |child| visit(child, opts) }
        end

        def visit_and(node, opts = EMPTY_HASH)
          left, right = node

          visit(left, opts)
          visit(right, opts)
        end

        def visit_key(node, opts = EMPTY_HASH)
          name, rest = node
          visit(rest, property: name)
        end

        def visit_predicate(node, property: nil)
          name, rest = node

          if name.equal?(:key?)
            properties[rest[0][1]] = {}
          else
            type = PREDICATE_TO_TYPE[name]
            properties[property][:type] = type if type
          end
        end
      end
    end
  end
end
