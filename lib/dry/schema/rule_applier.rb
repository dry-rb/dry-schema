require 'dry/initializer'

require 'dry/schema/constants'
require 'dry/schema/config'
require 'dry/schema/result'
require 'dry/schema/messages'
require 'dry/schema/message_compiler'

module Dry
  module Schema
    class RuleApplier
      extend Dry::Initializer

      param :rules

      option :config, default: proc { Config.new }

      option :message_compiler, default: proc { MessageCompiler.new(Messages.setup(config)) }

      def call(input)
        results = EMPTY_ARRAY.dup

        rules.each do |name, rule|
          next if input.error?(name)
          result = rule.(input)
          results << result if result.failure?
        end

        input.concat(results)
      end

      def to_ast
        [:set, rules.values.map(&:to_ast)]
      end
    end
  end
end
