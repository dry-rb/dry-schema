# frozen_string_literal: true

require 'dry/schema'

RSpec.describe Dry::Schema::Result do
  subject(:schema) do
    Dry::Schema.define do
      required(:template).hash do
        required(:id).value(:integer, gt?: 0)
      end
    end
  end

  describe '#messages' do
    it 'returns failures for root key and hints for child keys' do
      result = schema.(template: nil)

      expect(result.messages.to_h)
        .to eql(template: [['must be a hash'], id: ['must be greater than 0']])
    end

    it 'returns hints for child keys' do
      result = schema.(template: {})

      expect(result.messages.to_h)
        .to eql(template: { id: ['is missing', 'must be an integer', 'must be greater than 0'] })
    end
  end
end
