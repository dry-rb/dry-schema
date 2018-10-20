require 'dry/schema/constants'
require 'dry/schema/dsl'
require 'dry/schema/definition'
require 'dry/schema/types'

require 'dry/core/extensions'

module Dry
  module Schema
    extend Dry::Core::Extensions

    InvalidSchemaError = Class.new(StandardError)

    # Define a schema
    #
    # @return [Definition]
    #
    # @api public
    def self.define(options = EMPTY_HASH, &block)
      DSL.new(options, &block).call
    end

    # Define a form schema
    #
    # @return [Definition]
    #
    # @api public
    def self.form(options = EMPTY_HASH, &block)
      define(options.merge(hash_type: :symbolized, type_registry: method(:resolve_type).to_proc.curry.(:form)), &block)
    end

    # Define a JSON schema
    #
    # @return [Definition]
    #
    # @api public
    def self.json(options = EMPTY_HASH, &block)
      define(hash_type: :symbolized, type_registry: method(:resolve_type).to_proc.curry.(:json), &block)
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
      type = types.registered?(key) ? types[key] : types[name.to_s]
      type.safe
    end

    # @api private
    def self.types
      Dry::Types
    end
  end
end

require 'dry/schema/extensions'
