# frozen_string_literal: true

module Dry
  module Schema
    # Info extension
    #
    # @api public
    module Info
      module SchemaMethods
        # Return information about keys and types
        #
        # @return [Hash<Symbol=>Hash>]
        #
        # @api public
        def info
          compiler = Info::SchemaCompiler.new
          compiler.call(to_ast)
          compiler.to_h
        end
      end
    end

    Processor.include(Info::SchemaMethods)
  end
end
