require 'dry/schema/processor'

module Dry
  module Schema
    class Params < Processor
      config.key_map_type = :stringified
      config.type_registry = config.type_registry.namespaced(:params)
    end
  end
end