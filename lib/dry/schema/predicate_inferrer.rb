require 'dry/core/cache'

module Dry
  module Schema
    # PredicateInferrer is used internally by `Macros::Value`
    # for inferring type-check predicates from type specs.
    #
    # @api private
    class PredicateInferrer
      extend Dry::Core::Cache

      TYPE_TO_PREDICATE = Hash.new do |hash, type|
        primitive = type.meta[:maybe] ? type.right.primitive : type.primitive

        if hash.key?(primitive)
          hash[primitive]
        else
          :"#{primitive.name.split('::').last.downcase}?"
        end
      end

      TYPE_TO_PREDICATE.update(
        Integer => :int?,
        NilClass => :none?,
        String => :str?
      ).freeze

      # Infer predicate identifier from the provided type
      #
      # @return [Symbol]
      #
      # @api private
      def self.[](type)
        fetch_or_store(type.hash) {
          predicates =
            if type.is_a?(Dry::Types::Sum) && !type.meta[:maybe]
              [self[type.left], self[type.right]]
            else
              TYPE_TO_PREDICATE[type]
            end

          Array(predicates).flatten
        }
      end
    end
  end
end
