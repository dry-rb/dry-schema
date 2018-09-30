require 'dry/schema/constants'
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
    def self.define(options = EMPTY_HASH, &block)
      dsl = DSL.new(options, &block)
      Definition.new(dsl.call, { type_schema: dsl.type_schema }.merge(options))
    end

    # Define a form schema
    #
    # @return [Definition]
    #
    # @api public
    def self.form(options = EMPTY_HASH, &block)
      define(hash_type: :symbolized, type_registry: method(:resolve_type).to_proc.curry.(:form), &block)
    end

    # Return configured paths to message files
    #
    # @return [Array<String>]
    #
    # @api public
    def self.messages_paths
      Messages::Abstract.config.paths
    end

    # @api private
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
