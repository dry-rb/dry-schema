# frozen_string_literal: true

require 'dry/core/extensions'

require 'dry/schema/constants'
require 'dry/schema/dsl'
require 'dry/schema/params'
require 'dry/schema/json'

module Dry
  module Schema
    extend Dry::Core::Extensions

    # Define a schema
    #
    # @return [Processor]
    #
    # @api public
    def self.define(**options, &block)
      DSL.new(options, &block).call
    end

    # Define a param schema
    #
    # @return [Params]
    #
    # @api public
    def self.Params(**options, &block)
      define(**options, processor_type: Params, &block)
    end
    singleton_class.send(:alias_method, :Form, :Params)

    # Define a JSON schema
    #
    # @return [JSON]
    #
    # @api public
    def self.JSON(**options, &block)
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
