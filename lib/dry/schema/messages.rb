# frozen_string_literal: true

module Dry
  module Schema
    # An API for configuring message backends
    #
    # @api private
    module Messages
      BACKENDS = {
        i18n: "I18n",
        yaml: "YAML"
      }.freeze

      module_function

      public def setup(config)
        namespace = config.namespace
        options = config.to_h.select { |k, _| Abstract.setting_names.include?(k) }

        messages = backend(config.backend).build(options)

        return messages.namespaced(namespace) if namespace

        messages
      end

      # Returns the backend for the given identifier (`:i18n` or `:yaml`), or the given object
      # itself if it can build messages, such as a subclass of {Abstract}
      #
      # The backend's `build` receives only the options for settings defined on {Abstract}. If a
      # subclass adds its own settings, they keep their defaults unless the subclass sets them.
      #
      # @api private
      public def backend(identifier)
        return identifier if identifier.respond_to?(:build)

        backend_class = BACKENDS.fetch(identifier) do
          raise invalid_backend_message(identifier)
        end

        Messages.const_get(backend_class)
      end

      # @api private
      private_class_method def invalid_backend_message(identifier)
        message =
          "#{identifier.inspect} is not a valid messages backend. Use :yaml, :i18n, " \
          "or an object that responds to #build, such as a subclass of #{Abstract}"

        # It's an easy mistake to pass a pre-built messages object instead of its class, so add a
        # hint for this case.
        if identifier.is_a?(Abstract)
          message += ". Pass the class (#{identifier.class}), not an instance."
        end

        message
      end
    end
  end
end
