require 'dry/equalizer'

module Dry
  module Schema
    class Result
      include Dry::Equalizer(:output, :errors)
      include Enumerable

      attr_reader :output
      attr_reader :results

      def initialize(output, results)
        @output = output
        @results = results
      end

      def success?
        results.empty?
      end

      def failure?
        !success?
      end
    end
  end
end
