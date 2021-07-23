# frozen_string_literal: true

require "dry/schema/constants"

module Dry
  module Schema
    # @api private
    module JSONSchema
      # @api private
      class SchemaCompiler
        PREDICATE_TO_TYPE = {
          array?: {type: "array"},
          bool?: {type: "boolean"},
          date?: {type: "string", format: "date"},
          date_time?: {type: "string", format: "date-time"},
          decimal?: {type: "number"},
          float?: {type: "number"},
          hash?: {type: "object"},
          int?: {type: "integer"},
          nil?: {type: "null"},
          str?: {type: "string"},
          time?: {type: "string", format: "time"},
          min_size?: {minLength: ->(v) { v.to_i }},
          max_size?: {maxLength: ->(v) { v.to_i }}
        }.freeze

        # @api private
        attr_reader :keys, :required

        # @api private
        def initialize(root: false)
          @keys = EMPTY_HASH.dup
          @required = Set.new
          @root = root
        end

        # @api private
        def to_h
          result = {
            type: "object", 
            properties: keys,
            required: required.to_a
          }
          result[:"$schema"] = "http://json-schema.org/draft-06/schema#" if root?
          result
        end

        # @api private
        def call(ast)
          visit(ast)
        end

        # @api private
        def visit(node, opts = EMPTY_HASH)
          meth, rest = node
          public_send(:"visit_#{meth}", rest, opts)
        end

        # @api private
        def visit_set(node, opts = EMPTY_HASH)
          target = (key = opts[:key]) ? self.class.new : self

          node.map { |child| target.visit(child, opts) }

          return unless key

          target_info = opts[:member] ? {items: target.to_h} : target.to_h
          type = opts[:member] ? "array" : "object"

          keys.update(key => {**keys[key], type: type, **target_info})
        end

        # @api private
        def visit_and(node, opts = EMPTY_HASH)
          left, right = node

          visit(left, opts)
          visit(right, opts)
        end

        # @api private
        def visit_implication(node, opts = EMPTY_HASH)
          node.each do |el|
            visit(el, **opts, required: false)
          end
        end

        # @api private
        def visit_each(node, opts = EMPTY_HASH)
          visit(node, opts.merge(member: true))
        end

        # @api private
        def visit_key(node, opts = EMPTY_HASH)
          name, rest = node

          if opts.fetch(:required, :true)
            required << name.to_s
          else
            opts.delete(:required)
          end

          visit(rest, opts.merge(key: name))
        end

        # @api private
        def visit_not(node, opts = EMPTY_HASH)
          _name, rest = node

          visit_predicate(rest, opts)
        end

        # @api private
        def visit_predicate(node, opts = EMPTY_HASH)
          name, rest = node
          key = opts[:key]

          if name.equal?(:key?)
            prop_name = rest[0][1]
            keys[prop_name] = {}
          else
            type_opts = PREDICATE_TO_TYPE.fetch(name) { EMPTY_HASH }.dup
            type_opts.transform_values! { |v| v.respond_to?(:call) ? v.call(rest[0][1]) : v }
            merge_opts!(keys[key], type_opts)
          end
        end

        # @api private
        def merge_opts!(orig_opts, new_opts)
          new_type = new_opts[:type]
          orig_type = orig_opts[:type]
          new_opts[:type] = [orig_type, new_type] if orig_type && new_type

          orig_opts.merge!(new_opts)
        end

        # @api private
        def root?
          @root
        end
      end
    end
  end
end
