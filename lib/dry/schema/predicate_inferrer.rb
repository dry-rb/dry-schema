require 'dry/core/cache'

module Dry
  module Schema
    class PredicateInferrer
      extend Dry::Core::Cache

      TYPE_TO_PREDICATE = Hash.new do |hash, type|
        primitive = type.maybe? ? type.right.primitive : type.primitive

        if hash.key?(primitive)
          hash[primitive]
        else
          :"#{primitive.name.downcase}?"
        end
      end

      TYPE_TO_PREDICATE.update(
        Integer => :int?,
        NilClass => :none?,
        String => :str?
      ).freeze

      def self.[](type)
        fetch_or_store(type.hash) { TYPE_TO_PREDICATE[type] }
      end
    end
  end
end
