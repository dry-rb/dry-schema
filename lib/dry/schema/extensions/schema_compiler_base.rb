# frozen_string_literal: true

# This file defines an abstract base class for compiling a Dry::Schema AST
# into some output format (e.g., JSON Schema, OpenAPI Schema).
# Each subclass should override certain "abstract" methods to adapt the output.

require "dry/schema/constants"
require "set"

module Dry
  module Schema
    module SchemaCompilerBase
      IDENTITY = ->(v, _) { v }.freeze
      TO_INTEGER = ->(v, _) { v.to_i }.freeze

      # This base class contains all the common logic for compiling a schema AST.
      # Subclasses must implement the abstract methods:
      #   - predicate_to_type
      #   - fetch_filled_options
      #   - merge_or!
      #   - schema_info
      #   - schema_type
      #   - schema_method
      #
      # The shape of AST nodes (roughly):
      #   [:set, [ ... ]]
      #   [:key, [name, [ ... ]]]
      #   [:predicate, [predicate_name, [arg_name, arg_val], ...]]
      # etc.
      class Base
        UnknownConversionError = ::Class.new(::StandardError)

        attr_reader :keys, :required

        def initialize(root: false, loose: false)
          @keys     = EMPTY_HASH.dup
          @required = Set.new
          @root     = root
          @loose    = loose
        end

        def to_hash
          result = {}
          result.merge!(schema_info) if root?
          result.merge!(type: "object", properties: keys, required: required.to_a)
          result
        end
        alias_method :to_h, :to_hash

        def call(ast)
          visit(ast)
        end

        def visit(node, opts = EMPTY_HASH)
          meth, rest = node
          public_send(:"visit_#{meth}", rest, opts)
        end

        def visit_set(node, opts = EMPTY_HASH)
          # If a key is present we want to build a nested schema
          target = opts[:key] ? self.class.new(root: false, loose: loose?) : self

          node.each { |child| target.visit(child, opts.except(:member)) }

          if opts[:key]
            target_info = opts[:member] ? {items: target.to_h} : target.to_h
            type = opts[:member] ? "array" : "object"
            merge_opts!(keys[opts[:key]], {type: type, **target_info})
          end
        end

        def visit_and(node, opts = EMPTY_HASH)
          left, right = node
          # We reorder if left starts with :filled? so we know the type first
          if left[1][0] == :filled?
            visit(right, opts)
            visit(left, opts)
          else
            visit(left, opts)
            visit(right, opts)
          end
        end

        def visit_or(node, opts = EMPTY_HASH)
          # Process each alternative and merge using a custom "or" merger (anyOf vs oneOf)
          node.each do |child|
            c = self.class.new(root: false, loose: loose?)
            c.keys.update(subschema: {})
            c.visit(child, opts.merge(key: :subschema))
            merge_or!(keys[opts[:key]], c.keys[:subschema])
          end
        end

        # :implication means "if left, then right." But for schema compilation,
        # we simply visit both with required: false so that it doesn't always enforce them.
        def visit_implication(node, opts = EMPTY_HASH)
          node.each { |el| visit(el, **opts, required: false) }
        end

        def visit_each(node, opts = EMPTY_HASH)
          visit(node, opts.merge(member: true))
        end

        def visit_key(node, opts = EMPTY_HASH)
          name, rest = node
          if opts.fetch(:required, true)
            required << name.to_s
          else
            # If not required, remove it from opts so sub-rules won't re-add it
            opts.delete(:required)
          end
          visit(rest, opts.merge(key: name))
        end

        def visit_not(node, opts = EMPTY_HASH)
          _name, rest = node
          visit_predicate(rest, opts)
        end

        def visit_predicate(node, opts = EMPTY_HASH)
          name, rest = node

          if name.equal?(:key?)
            keys[rest[0][1]] = {}
          else
            target = keys[opts[:key]]
            type_opts = fetch_type_opts_for_predicate(name, rest, target)
            if target[:type]&.include?("array")
              target[:items] ||= {}
              merge_opts!(target[:items], type_opts)
            else
              merge_opts!(target, type_opts)
            end
          end
        end

        def fetch_type_opts_for_predicate(name, rest, target)
          type_opts = predicate_to_type.fetch(name) do
            raise_unknown_conversion_error!(:predicate, name) unless loose?
            EMPTY_HASH
          end.dup
          type_opts.transform_values! do |v|
            v.respond_to?(:call) ? v.call(rest[0][1], target) : v
          end
          type_opts.merge!(fetch_filled_options(target[:type], target)) if name == :filled?
          type_opts
        end

        def merge_opts!(orig_opts, new_opts)
          new_type = new_opts[:type]
          orig_type = orig_opts[:type]
          if orig_type && new_type && orig_type != new_type
            new_opts[:type] = [orig_type, new_type].flatten.uniq
          end
          orig_opts.merge!(new_opts)
        end

        def raise_unknown_conversion_error!(type, name)
          # Build a helpful message explaining that we couldn’t convert this type/predicate
          # and they can use loose: true to ignore unknowns.
          # This error is particularly helpful if new predicates are added to Dry::Schema
          # that aren't yet handled in the compiler.

          message = unknown_conversion_message(type, name)
          raise UnknownConversionError, message.chomp
        end

        def root?
          @root
        end

        def loose?
          @loose
        end

        # === Abstract methods to be implemented by subclasses ===

        # Returns a hash mapping predicate names to schema options.
        def predicate_to_type
          raise NotImplementedError, "#{self.class.name} must implement `predicate_to_type`"
        end

        # Returns extra options for the :filled? predicate based on the type.
        def fetch_filled_options(_type, _target)
          {}
        end

        # Merges an “or” branch into the parent schema.
        # By default, JSON Schema uses "anyOf", but OpenAPI might use "oneOf".
        def merge_or!(target, new_schema)
          (target[:anyOf] ||= []) << new_schema
        end

        # Additional information to merge at the root level (e.g. $schema for JSON Schema).
        def schema_info
          {}
        end

        # Returns the name of the schema type (e.g. "JSON" or "OpenAPI") for error messages.
        def schema_type
          raise NotImplementedError, "#{self.class.name} must implement `schema_type`"
        end

        # Returns the schema method name (e.g. "json_schema" or "open_api_schema") for error messages.
        def schema_method
          raise NotImplementedError, "#{self.class.name} must implement `schema_method`"
        end

        def unknown_conversion_message(type, name)
          <<~MSG
            Could not find an equivalent conversion for #{type} #{name.inspect}.

            This means that your generated #{schema_type} schema may be missing this validation.

            You can ignore this by generating the schema in "loose" mode, i.e.:
                my_schema.#{schema_method}(loose: true)
          MSG
        end
      end
    end
  end
end
