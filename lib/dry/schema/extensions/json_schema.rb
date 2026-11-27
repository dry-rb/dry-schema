# frozen_string_literal: true

require "dry/schema/extensions/json_schema/schema_compiler"

module Dry
  module Schema
    # JSONSchema extension
    #
    # @api public
    module JSONSchema
      module SchemaMethods
        # Convert the schema into a JSON schema hash
        #
        # @param [Symbol] loose Compile the schema in "loose" mode
        #
        # @return [Hash<Symbol=>Hash>]
        #
        # @api public
        def json_schema(loose: false)
          compiler = SchemaCompiler.new(root: true, loose: loose, type_schema: type_schema)
          compiler.call(to_ast)
          compiler.to_hash
        end
      end

      module MacroMethods
        # Attach JSON Schema documentation metadata to this key
        #
        # @example
        #   required(:email).filled(:string).documentation(description: "User email", example: "a@b.com")
        #
        # @return [self]
        #
        # @api public
        def documentation(title: nil, description: nil, examples: nil, example: nil, deprecated: false)
          if schema_dsl.types[name].is_a?(Dry::Types::AnyClass)
            raise ::Dry::Schema::InvalidSchemaError,
              ".documentation must be called after a type is set (e.g. after .filled or .value)"
          end
          attrs = {
            title: title, description: description,
            examples: examples, example: example,
            deprecated: deprecated || nil
          }.compact
          current = schema_dsl.types[name].meta[:json_schema] || {}
          schema_dsl.types[name] = schema_dsl.types[name].meta(json_schema: current.merge(attrs))
          self
        end
      end
    end

    Processor.include(JSONSchema::SchemaMethods)
    Macros::Core.include(JSONSchema::MacroMethods)
  end
end
