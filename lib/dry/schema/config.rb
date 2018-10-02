require 'delegate'
require 'dry/configurable'

require 'dry/schema/predicate_registry'

module Dry
  module Schema
    class Config < SimpleDelegator
      extend Dry::Configurable

      setting :predicates, Schema::PredicateRegistry.new
      setting :messages, :yaml
      setting :messages_file
      setting :namespace
      setting :rules, {}

      def self.new
        super(struct.new(*settings.map { |key| config.public_send(key) }))
      end

      def self.struct
        ::Struct.new(*settings)
      end

      def configure(&block)
        yield(__getobj__)
        values.freeze
        freeze
      end
    end
  end
end
