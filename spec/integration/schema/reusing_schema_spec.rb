# frozen_string_literal: true

RSpec.describe 'Reusing schemas' do
  subject(:schema) do
    Dry::Schema.define do
      required(:city).filled

      required(:location).schema(LocationSchema)
    end
  end

  before do
    LocationSchema = Dry::Schema.define do
      required(:lat).filled(:float?)
      required(:lng).filled(:float?)
    end
  end

  after do
    Object.send(:remove_const, :LocationSchema)
  end

  it 're-uses existing schema' do
    expect(schema.(city: 'NYC', location: { lat: 1.23, lng: 45.6 })).to be_success

    expect(schema.(city: 'NYC', location: { lat: nil, lng: '45.6' }).messages).to eql(
      location: {
        lat: ['must be filled'],
        lng: ['must be a float']
      }
    )
  end

  context 'when overrides existing schema' do
    subject(:schema) do
      Dry::Schema.define do
        required(:city).filled

        required(:location).schema(LocationSchema) do
          required(:lat).filled(:float?, gteq?: 18)
        end
      end
    end

    it 'uses new schema' do
      expect(
        schema.(city: 'NYC', location: { lat: 1.23, lng: nil }).messages
      ).to eql(location: { lat: ['must be greater than or equal to 18'], lng: ['must be filled'] })
    end
  end
end
