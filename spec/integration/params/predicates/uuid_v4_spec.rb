# frozen_string_literal: true

require 'securerandom'

RSpec.describe 'Predicates: uuid_v4?' do
  subject(:schema) do
    Dry::Schema.Params do
      required(:uuid).value(:string, :uuid_v4?)
    end
  end

  it 'passes with valid input' do
    expect(schema.(uuid: SecureRandom.uuid)).to be_success
  end

  it 'fails with invalid input' do
    expect(schema.(uuid: 'not-uuid').errors.to_h).to eql(uuid: ['is not a valid UUID'])
  end
end
