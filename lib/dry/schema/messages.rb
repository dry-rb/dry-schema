# frozen_string_literal: true

module Dry
  module Schema
    # An API for configuring message backends
    #
    # @api private
    module Messages
      module_function

      public def setup(config)
        messages = build(config.backend)
        namespace = config.namespace

        if config.load_paths.any? && namespace
          messages.merge(config.load_paths).namespaced(namespace)
        elsif config.load_paths.any?
          messages.merge(config.load_paths)
        elsif namespace
          messages.namespaced(namespace)
        else
          messages
        end
      end

      # @api private
      def build(backend)
        klass =
          case backend
          when :yaml then default
          when :i18n then const_get(:I18n)
          else
            raise "+#{backend}+ is not a valid messages identifier"
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
