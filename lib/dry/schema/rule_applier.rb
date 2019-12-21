# frozen_string_literal: true

require 'dry/initializer'

require 'dry/schema/constants'
require 'dry/schema/config'
require 'dry/schema/result'
require 'dry/schema/messages'
require 'dry/schema/message_compiler'
require 'dry/schema/ast_error_compiler'

module Dry
  module Schema
    # Applies rules defined within the DSL
    #
    # @api private
    class RuleApplier
      extend Dry::Initializer

      # @api private
      param :rules

      # @api private
      option :config, default: -> { Config.new }

      # @api private
      option :message_compiler, default: (proc do
        if config.error_compiler == :ast
          AstErrorCompiler.new
        else
          MessageCompiler.new(Messages.setup(config.messages))
        end
      end)

      # @api private
      def call(input)
        results = EMPTY_ARRAY.dup

        rules.each do |name, rule|
          next if input.error?(name)

          result = rule.(input.to_h)
          results << result if result.failure?
        end

        input.concat(results)
      end

      # @api private
      def to_ast
        if config.messages.namespace
          [:namespace, [config.messages.namespace, [:set, rules.values.map(&:to_ast)]]]
        else
          [:set, rules.values.map(&:to_ast)]
        end
      end
    end
  end
end
