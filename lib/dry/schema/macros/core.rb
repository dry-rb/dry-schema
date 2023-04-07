# frozen_string_literal: true

require "dry/initializer"
require "dry/schema/constants"

module Dry
  module Schema
    module Macros
      # Abstract macro class
      #
      # @api private
      class Core
        extend Dry::Initializer

        # @api private
        option :name, default: proc {}, optional: true

        # @api private
        option :compiler, default: proc { Compiler.new }

        # @api private
        option :trace, default: proc { Trace.new }

        # @api private
        option :schema_dsl, optional: true

        # @api private
        def new(klass: self.class, **options)
          klass.new(name: name, compiler: compiler, schema_dsl: schema_dsl, **options)
        end

        # @api private
        def path
          schema_dsl.path
        end

        # @api private
        def to_rule
          compiler.visit(to_ast)
        end

        # @api private
        def to_ast(*)
          trace.to_ast
        end
        alias_method :ast, :to_ast

        # @api private
        def operation
          raise NotImplementedError
        end
      end
    end
  end
end
