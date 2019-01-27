module Dry
  module Schema
    module Messages
      # Namespaced messages backend
      #
      # @api public
      class Namespaced <Dry::Schema::Messages::Abstract
        # @api private
        attr_reader :namespace

        # @api private
        attr_reader :messages

        # @api private
        attr_reader :root

        # @api private
        def initialize(namespace, messages)
          super()
          @namespace = namespace
          @messages = messages
          @root = messages.root
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
          super(tokens.merge(root: "#{root}.rules.#{namespace}")) + super
        end
      end
    end
  end
end
