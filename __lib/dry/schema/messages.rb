module Dry
  module Schema
    module Messages
      def self.default
        Messages::YAML.load
      end
    end
  end
end

require 'dry/schema/messages/abstract'
require 'dry/schema/messages/namespaced'
require 'dry/schema/messages/yaml'
require 'dry/schema/messages/i18n' if defined?(I18n)
