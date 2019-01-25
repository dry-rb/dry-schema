require 'dry/schema/processor'

module Dry
  module Schema
    class JSON < Processor
      config.key_map_type = :stringified
      config.type_registry = config.type_registry.namespaced(:json)
    end
  end
end