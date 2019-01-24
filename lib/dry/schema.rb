require 'dry/core/extensions'

require 'dry/schema/constants'
require 'dry/schema/dsl'
require 'dry/schema/definition'
require 'dry/schema/type_registry'

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

    # Define a param schema
    #
    # @return [Definition]
    #
    # @api public
    def self.params(options = EMPTY_HASH, &block)
      dsl_opts = options.merge(
        hash_type: :symbolized, type_registry: type_registry.namespaced(:params)
      )
      define(dsl_opts, &block)
    end
    singleton_class.send(:alias_method, :form, :params)

    # Define a JSON schema
    #
    # @return [Definition]
    #
    # @api public
    def self.json(options = EMPTY_HASH, &block)
      dsl_opts = options.merge(
        hash_type: :symbolized, type_registry: type_registry.namespaced(:json)
      )
      define(dsl_opts, &block)
    end

    # Return configured paths to message files
    #
    # @return [Array<String>]
    #
    # @api public
    def self.messages_paths
      Messages::Abstract.config.paths
    end

    def self.type_registry
      @__type_registry__ ||= TypeRegistry.new
    end
  end
end

require 'dry/schema/extensions'
