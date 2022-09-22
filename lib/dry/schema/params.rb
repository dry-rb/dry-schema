# frozen_string_literal: true

require "dry/schema/processor"

module Dry
  module Schema
    # Params schema type
    #
    # @see Processor
    # @see Schema#Params
    #
    # @api public
    class Params < Processor
      configure do |config|
        config.key_map_type = :stringified
        config.type_registry_namespace = :params
        config.filter_empty_string = true
      end
    end
  end
end
