# frozen_string_literal: true

require 'dry/equalizer'
require 'dry/configurable'
require 'dry/schema/predicate_registry'

module Dry
  module Schema
    # Schema definition configuration class
    #
    # @see DSL#configure
    #
    # @api public
    class Config
      include Dry::Configurable
      include Dry::Equalizer(:predicates, :messages)

      setting(:predicates, Schema::PredicateRegistry.new)

      setting(:messages) do
        setting(:backend, :yaml)
        setting(:namespace)
        setting(:load_paths, EMPTY_ARRAY, &:dup)
      end

      # Return configured predicate registry
      #
      # @return [Schema::PredicateRegistry]
      #
      # @api public
      def predicates
        config.predicates
      end

      # Return configuration for message backend
      #
      # @return [Dry::Configurable::Config]
      #
      # @api public
      def messages
        config.messages
      end
    end
  end
end
