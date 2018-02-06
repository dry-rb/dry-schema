require 'dry/schema'

RSpec.describe Dry::Schema, '.define' do
  shared_context 'valid schema' do
    it 'passes when input is valid' do
      expect(schema.(email: 'jane@doe')).to be_success
    end

    it 'fails when input is not valid' do
      expect(schema.(email: nil)).to be_failure
    end
  end

  context 'using macros' do
    subject(:schema) do
      Dry::Schema.define do
        required(:email).filled(:str?)
      end
    end

    include_context 'valid schema'
  end

  context 'using a block' do
    subject(:schema) do
      Dry::Schema.define do
        required(:email) { filled? & str? }
      end
    end

    include_context 'valid schema'
  end
end
