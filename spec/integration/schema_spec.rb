require 'dry/schema'

RSpec.describe Dry::Schema, '.define' do
  subject(:schema) do
    Dry::Schema.define do
      required(:email).filled(:str?)
    end
  end

  it 'passes when input is valid' do
    expect(schema.(email: 'jane@doe')).to be_success
  end

  it 'fails when input is not valid' do
    expect(schema.(email: nil)).to be_failure
  end
end
