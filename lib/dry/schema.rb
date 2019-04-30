# frozen_string_literal: true

require 'dry/core/extensions'

require 'dry/schema/constants'
require 'dry/schema/dsl'
require 'dry/schema/params'
require 'dry/schema/json'

module Dry
  # Main interface
  #
  # @api public
  module Schema
    extend Dry::Core::Extensions

    # Define a schema
    #
    # @example
    #   Dry::Schema.define do
    #     required(:name).filled(:string)
    #     required(:age).value(:integer, gt?: 0)
    #   end
    #
    # @param [Hash] options
    #
    # @return [Processor]
    #
    # @see DSL.new
    #
    # @api public
    def self.define(**options, &block)
      DSL.new(options, &block).call
    end

    # Define a schema suitable for HTTP params
    #
    # This schema type uses `Types::Params` for coercion by default
    #
    # @example
    #   Dry::Schema.Params do
    #     required(:name).filled(:string)
    #     required(:age).value(:integer, gt?: 0)
    #   end
    #
    # @return [Params]
    #
    # @see Schema#define
    #
    # @api public
    def self.Params(**options, &block)
      define(**options, processor_type: Params, &block)
    end
    singleton_class.send(:alias_method, :Form, :Params)

    # Define a schema suitable for JSON data
    #
    # This schema type uses `Types::JSON` for coercion by default
    #
    # @example
    #   Dry::Schema.JSON do
    #     required(:name).filled(:string)
    #     required(:age).value(:integer, gt?: 0)
    #   end
    #
    # @return [Params]
    #
    # @see Schema#define
    #
    # @api public
    def self.JSON(**options, &block)
      define(**options, processor_type: JSON, &block)
    end
  end
end

require 'dry/schema/extensions'
