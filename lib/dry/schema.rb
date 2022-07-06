# frozen_string_literal: true

require "zeitwerk"

require "dry/core"
require "dry/schema/constants"

module Dry
  # Main interface
  #
  # @api public
  module Schema
    extend Dry::Core::Extensions
    require "dry/schema/extensions"

    # @api private
    def self.loader
      @loader ||= Zeitwerk::Loader.new.tap do |loader|
        root = File.expand_path("..", __dir__)
        loader.tag = "dry-schema"
        loader.inflector = Zeitwerk::GemInflector.new("#{root}/dry-schema.rb")
        loader.inflector.inflect("dsl" => "DSL")
        loader.push_dir(root)
        loader.ignore("#{root}/dry-schema.rb")
        loader.inflector.inflect("i18n" => "I18n", "yaml" => "YAML", "json" => "JSON")
      end
    end

    loader.setup

    # Configuration
    #
    # @example
    #   Dry::Schema.config.messages.backend = :i18n
    #
    # @return [Config]
    #
    # @api public
    def self.config
      @config ||= Config.new
    end

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
      DSL.new(**options, &block).call
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
