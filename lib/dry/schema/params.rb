require 'dry/schema/processor'

module Dry
  module Schema
    # Params schema type
    #
    # @see Processor
    # @see Schema.params
    #
    # @api public
    class Params < Processor
      config.key_map_type = :stringified
      config.type_registry = config.type_registry.namespaced(:params)
    end
  end
end