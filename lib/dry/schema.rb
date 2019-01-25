require 'dry/core/extensions'

require 'dry/schema/constants'
require 'dry/schema/dsl'
require 'dry/schema/params'
require 'dry/schema/json'

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
    def self.params(**options, &block)
      define(**options, processor_type: Params, &block)
    end
    singleton_class.send(:alias_method, :form, :params)

    # Define a JSON schema
    #
    # @return [Definition]
    #
    # @api public
    def self.json(**options, &block)
      define(**options, processor_type: JSON, &block)
    end

    # Return configured paths to message files
    #
    # @return [Array<String>]
    #
    # @api public
    def self.messages_paths
      Messages::Abstract.config.paths
    end
  end
end

require 'dry/schema/extensions'
