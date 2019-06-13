# frozen_string_literal: true

RSpec.describe 'Params / Constructor Types' do
  context 'an array which rejects empty values' do
    subject(:schema) do
      Dry::Schema.Params do
        required(:nums).filled(Test::SanitizedArray)
      end
    end

    before do
      module Test
        SanitizedArray = Types::Params::Array
          .of(Types::Params::Integer)
          .constructor { |arr| arr.reject(&:empty?) }
      end
    end

    it 'passes even when the array includes empty values' do
      result = schema.(nums: ['1', '', '2'])

      expect(result).to be_success
      expect(result.to_h).to eql(nums: [1, 2])
    end

    it 'fails when the array is empty' do
      result = schema.(nums: ['', ''])

      expect(result.errors).to eql(nums: ['must be filled'])
      expect(result.to_h).to eql(nums: [])
    end
  end
end
