# frozen_string_literal: true

require 'dry/schema/extensions/open_api/schema_compiler'

module Dry
  module Schema
    # Open API extension
    #
    # @api public
    module OpenAPI
      module SchemaMethods
        def to_open_api
          compiler = SchemaCompiler.new
          compiler.call(to_ast)
          compiler.to_h
        end
      end
    end

    Processor.include(OpenAPI::SchemaMethods)
  end
end
