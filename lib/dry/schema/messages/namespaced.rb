# frozen_string_literal: true

module Dry
  module Schema
    module Messages
      # Namespaced messages backend
      #
      # @api public
      class Namespaced < Dry::Schema::Messages::Abstract
        # @api private
        attr_reader :namespace

        # @api private
        attr_reader :messages

        # @api private
        attr_reader :config

        # @api private
        attr_reader :call_opts

        # @api private
        def initialize(namespace, messages)
          @config = messages.config
          @namespace = namespace
          @messages = messages
          @call_opts = { namespace: namespace }.freeze
        end

        # Get a message for the given key and its options
        #
        # @param [Symbol] key
        # @param [Hash] options
        #
        # @return [String]
        #
        # @api public
        def get(key, options = {})
          messages.get(key, options)
        end

        # @api public
        def call(key, options = {})
          super(key, options.empty? ? call_opts : options.merge(call_opts))
        end
        alias_method :[], :call

        # Check if given key is defined
        #
        # @return [Boolean]
        #
        # @api public
        def key?(key, *args)
          messages.key?(key, *args)
        end

        # @api private
        def lookup_paths(tokens)
          super(tokens.merge(root: "#{tokens[:root]}.#{namespace}")) + super
        end

        # @api private
        def rule_lookup_paths(tokens)
          base_paths = messages.rule_lookup_paths(tokens)
          base_paths.map { |key| key.gsub('dry_schema', "dry_schema.#{namespace}") } + base_paths
        end
      end
    end
  end
end
