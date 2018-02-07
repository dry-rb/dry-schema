require 'dry/initializer'

require 'dry/schema/dsl'
require 'dry/schema/result'
require 'dry/schema/messages'
require 'dry/schema/message_compiler'

module Dry
  module Schema
    class Definition
      extend Dry::Initializer

      param :rules

      option :message_compiler, default: proc { MessageCompiler.new(Messages.default) }

      # Define a new schema definition
      #
      # @return [Definition]
      #
      # @api public
      def self.new(compiler, &block)
        dsl = DSL.new(compiler, &block)
        super(dsl.call)
      end

      def call(input)
        results = rules.reduce([]) { |a, (name, rule)|
          result = rule.(input)
          a << result unless result.success?
          a
        } || EMPTY_ARRAY

        Result.new(input, results, message_compiler: message_compiler)
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
