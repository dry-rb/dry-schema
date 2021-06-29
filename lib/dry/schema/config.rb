# frozen_string_literal: true

require "dry/core/equalizer"
require "dry/configurable"
require "dry/configurable/version"

require "dry/schema/constants"
require "dry/schema/predicate_registry"
require "dry/schema/type_container"

module Dry
  module Schema
    # Schema definition configuration class
    #
    # @see DSL#configure
    #
    # @api public
    class Config
      include Dry::Configurable
      include Dry::Equalizer(:to_h, inspect: false)

      unless Dry::Configurable::VERSION < "0.13"
        def self.setting(name, default = Undefined, **opts, &block)
          return super if default.equal?(Undefined)
          super(name, **opts.merge(default: default), &block)
        end
      end

      # @!method predicates
      #
      # Return configured predicate registry
      #
      # @return [Schema::PredicateRegistry]
      #
      # @api public
      setting :predicates, Schema::PredicateRegistry.new

      # @!method types
      #
      # Return configured container with extra types
      #
      # @return [Hash]
      #
      # @api public
      setting :types, Dry::Types

      # @!method messages
      #
      # Return configuration for message backend
      #
      # @return [Dry::Configurable::Config]
      #
      # @api public
      setting :messages do
        setting :backend, :yaml
        setting :namespace
        setting :load_paths, Set[DEFAULT_MESSAGES_PATH], constructor: :dup.to_proc
        setting :top_namespace, DEFAULT_MESSAGES_ROOT
        setting :default_locale
      end

      # @!method validate_keys
      #
      # On/off switch for key validator
      #
      # @return [Boolean]
      #
      # @api public
      setting :validate_keys, false

      # @api private
      def respond_to_missing?(meth, include_private = false)
        super || config.respond_to?(meth, include_private)
      end

      # @api private
      def inspect
        "#<#{self.class} #{to_h.map { |k, v| ["#{k}=", v.inspect] }.map(&:join).join(" ")}>"
      end

      private

      # Forward to the underlying config object
      #
      # @api private
      def method_missing(meth, *args, &block)
        super unless config.respond_to?(meth)
        config.public_send(meth, *args)
      end
    end
  end
end
