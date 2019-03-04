# frozen_string_literal: true

require 'delegate'
require 'dry/configurable'

require 'dry/schema/predicate_registry'

module Dry
  module Schema
    # Schema definition configuration class
    #
    # @see DSL#configure
    #
    # @api public
    class Config < SimpleDelegator
      extend Dry::Configurable

      setting :predicates, Schema::PredicateRegistry.new
      setting :messages, :yaml
      setting :messages_file
      setting :namespace
      setting :rules, {}

      # Build a new config object with defaults filled in
      #
      # @api private
      def self.new
        super(struct.new(*settings.map { |key| config.public_send(key) }))
      end

      # Build a struct with defined settings
      #
      # @return [Struct]
      #
      # @api private
      def self.struct
        ::Struct.new(*settings)
      end

      # Expose configurable object to the provided block
      #
      # This method is used by `DSL#configure`
      #
      # @return [Config]
      #
      # @api private
      def configure(&block)
        yield(__getobj__)
        values.freeze
        freeze
      end
    end
  end
end
