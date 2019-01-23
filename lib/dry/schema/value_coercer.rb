require 'dry/initializer'

module Dry
  module Schema
    class ValueCoercer
      extend Dry::Initializer

      param :type_schema

      def call(input)
        if input.success?
          type_schema[Hash(input)]
        else
          type_schema.member_types.reduce(EMPTY_HASH.dup) do |hash, (name, type)|
            hash[name] = input.error?(name) ? input[name] : type[input[name]]
            hash
          end
        end
      end
    end
  end
end
