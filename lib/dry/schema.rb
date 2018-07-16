require 'dry/schema/compiler'
require 'dry/schema/dsl'
require 'dry/schema/definition'
require 'dry/schema/types'

module Dry
  module Schema
    InvalidSchemaError = Class.new(StandardError)

    # Define a schema
    #
    # @return [Definition]
    #
    # @api public
    def self.define(options = {}, &block)
      compiler = Compiler.new
      dsl = DSL.new(compiler, options, &block)

      Definition.new(dsl.call, { type_schema: dsl.type_schema }.merge(options))
    end

    # Define a form schema
    #
    # @return [Definition]
    #
    # @api public
    def self.form(options = {}, &block)
      define(hash_type: :symbolized, type_registry: method(:resolve_type).to_proc.curry.(:form), &block)
    end

    # @api privage
    def self.resolve_type(ns, name)
      key = "#{ns}.#{name}"
      types.registered?(key) ? types[key] : types[name.to_s]
    end

    # @api private
    def self.types
      Dry::Types
    end
  end
end
