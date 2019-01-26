require 'dry/core/cache'

module Dry
  module Schema
    class PredicateInferrer
      extend Dry::Core::Cache

      TYPE_TO_PREDICATE = ::Hash.new { |hash, type|
        primitive = type.maybe? ? type.right.primitive : type.primitive

        if hash.key?(primitive)
          hash[primitive]
        else
          :"#{primitive.name.downcase}?"
        end
      }.update(Integer => :int?, String => :str?).freeze

      def self.[](type)
        fetch_or_store(type.hash) { TYPE_TO_PREDICATE[type] }
      end
    end
  end
end