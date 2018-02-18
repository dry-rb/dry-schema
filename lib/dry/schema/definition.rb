require 'dry/initializer'

require 'dry/schema/result'
require 'dry/schema/messages'
require 'dry/schema/message_compiler'

module Dry
  module Schema
    class Definition
      DEFAULT_HASH_SCHEMA = -> h { h }

      extend Dry::Initializer

      param :rules

      option :message_compiler, default: proc { MessageCompiler.new(Messages.default) }

      option :type_schema, default: proc { DEFAULT_HASH_SCHEMA }

      def call(input)
        processed = type_schema[input]

        results = rules.reduce([]) { |a, (name, rule)|
          result = rule.(processed)
          a << result unless result.success?
          a
        } || EMPTY_ARRAY

        Result.new(processed, results, message_compiler: message_compiler)
      end

      def to_ast
        [:set, rules.values.map(&:to_ast)]
      end

      def to_rule
        self
      end
    end
  end
end
