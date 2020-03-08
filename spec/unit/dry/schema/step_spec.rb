# frozen_string_literal: true

require 'dry/schema/step'

RSpec.describe Dry::Schema::Step do
  describe '#call' do
    context 'when scoped with a deep path' do
      subject(:step) do
        root_step.scoped([:foo, :bar])
      end

      let(:root_step) do
        Dry::Schema::Step.new(type: :core, name: :rule_applier, executor: lambda { |result|
          result.update(test: true)
        })
      end

      it 'updates results using nested path' do
        result = Dry::Schema::Result.new({ foo: { bar: {} } }, message_compiler: proc {}) do |r|
          step.(r)
        end

        expect(result.to_h).to eql(foo: { bar: { test: true } })
      end
    end
  end
end
