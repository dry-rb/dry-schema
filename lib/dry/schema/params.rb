# frozen_string_literal: true

require 'dry/schema/processor'

module Dry
  module Schema
    # Params schema type
    #
    # @see Processor
    # @see Schema#Params
    #
    # @api public
    class Params < Processor
      config.key_map_type = :stringified
      config.type_registry = config.type_registry.namespaced(:params)
      config.filter_empty_string = true
    end
  end
end
