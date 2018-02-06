require 'dry/schema'

RSpec.describe Dry::Schema, '.define' do
  shared_context 'valid schema' do
    it 'passes when input is valid' do
      expect(schema.(email: 'jane@doe')).to be_success
      expect(schema.(email: 'jane@doe', age: 21)).to be_success
    end

    it 'fails when input is not valid' do
      expect(schema.(email: nil)).to be_failure
      expect(schema.(email: nil, age: 21)).to be_failure
      expect(schema.(email: nil, age: '21')).to be_failure
    end
  end

  context 'using macros' do
    subject(:schema) do
      Dry::Schema.define do
        required(:email).filled(:str?)
        optional(:age).value(:int?)
      end
    end

    include_context 'valid schema'
  end

  context 'using a block' do
    subject(:schema) do
      Dry::Schema.define do
        required(:email) { filled? & str? }
        optional(:age) { int? }
      end
    end

    include_context 'valid schema'
  end

  context 'chaining calls' do
    subject(:schema) do
      Dry::Schema.define do
        required(:email).value(:str?).filled
        optional(:age).value(:int?)
      end
    end

    include_context 'valid schema'
  end

  context 'each macro' do
    subject(:schema) do
      Dry::Schema.define do
        required(:tags).each(:str?) { size?(2..4) }
      end
    end

    it 'passes when input is valid' do
      expect(schema.(tags: ['red', 'blue'])).to be_success
    end

    it 'fails when input is not valid' do
      expect(schema.(tags: ['red', nil])).to be_failure
      expect(schema.(tags: ['red', 'black'])).to be_failure
    end
  end
end
