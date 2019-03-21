# frozen_string_literal: true

module Dry
  module Schema
    # An API for configuring message backends
    #
    # @api private
    module Messages
      module_function

      public def setup(config)
        messages = build(config)

        if config.messages_file && config.namespace
          messages.merge(config.messages_file).namespaced(config.namespace)
        elsif config.messages_file
          messages.merge(config.messages_file)
        elsif config.namespace
          messages.namespaced(config.namespace)
        else
          messages
        end
      end

      # @api private
      def build(config)
        klass =
          case config.messages
          when :yaml then default
          when :i18n then const_get(:I18n)
          else
            raise "+#{config.messages}+ is not a valid messages identifier"
          end

        klass.build
      end

      # @api private
      def default
        const_get(:YAML)
      end
    end
  end
end

require 'dry/schema/messages/abstract'
require 'dry/schema/messages/namespaced'
require 'dry/schema/messages/yaml'
require 'dry/schema/messages/i18n' if defined?(I18n)
