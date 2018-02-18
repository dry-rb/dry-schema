require 'dry/initializer'
require 'dry/equalizer'

module Dry
  module Schema
    class Result
      include Dry::Equalizer(:output, :errors)

      extend Dry::Initializer

      param :output

      param :results

      option :message_compiler

      def success?
        results.empty?
      end

      def failure?
        !success?
      end

      def errors(options = EMPTY_HASH)
        message_set(options.merge(hints: false)).dump
      end

      def messages(options = EMPTY_HASH)
        message_set(options.merge(hints: true)).dump
      end

      def message_set(options = EMPTY_HASH)
        message_compiler.with(options).(result_ast)
      end

      private

      def result_ast
        @result_ast ||= results.map(&:to_ast)
      end
    end
  end
end
