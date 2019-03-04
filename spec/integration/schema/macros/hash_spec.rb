# frozen_string_literal: true

RSpec.describe 'Macros #hash' do
  subject(:schema) do
    Dry::Schema.define do
      required(:foo).hash do
        required(:bar).value(:string)
      end
    end
  end

  context 'with valid input' do
    let(:input) do
      { foo: { bar: 'valid' } }
    end

    it 'is successful' do
      expect(result).to be_successful
    end
  end

  context 'with invalid input' do
    let(:input) do
      { foo: { bar: 312 } }
    end

    it 'is not successful' do
      expect(result).to be_failing(bar: ['must be a string'])
    end
  end

  context 'with invalid input type' do
    let(:input) do
      { foo: nil }
    end

    it 'is not successful' do
      expect(result).to be_failing(['must be a hash'])
    end
  end
end
