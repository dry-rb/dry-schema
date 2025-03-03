# frozen_string_literal: true

require "dry/schema/extensions/open_api_schema/schema_compiler"

module Dry
  module Schema
    # OpenAPISchema extension
    #
    # @api public
    module OpenAPISchema
      module SchemaMethods
        # Convert the schema into a OpenAPI schema hash
        #
        # @param [Symbol] loose Compile the schema in "loose" mode
        #
        # @return [Hash<Symbol=>Hash>]
        #
        # @api public
        def open_api_schema(loose: false)
          compiler = SchemaCompiler.new(root: false, loose: loose)
          compiler.call(to_ast)
          compiler.to_hash
        end
      end
    end

    Processor.include(OpenAPISchema::SchemaMethods)
  end
end
