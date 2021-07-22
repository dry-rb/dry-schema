# frozen_string_literal: true

require "dry/schema/extensions/json_schema/schema_compiler"

module Dry
  module Schema
    # JSONSchema extension
    #
    # @api public
    module JSONSchema
      module SchemaMethods
        # Return information about keys and types
        #
        # @return [Hash<Symbol=>Hash>]
        #
        # @api public
        def json_schema
          return @json_schema if defined?(@json_schema)

          compiler = SchemaCompiler.new
          compiler.call(to_ast)

          @json_schema = compiler.to_h
        end
      end
    end

    Processor.include(JSONSchema::SchemaMethods)
  end
end
