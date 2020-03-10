# frozen_string_literal: true

RSpec.describe Dry::Schema, 'unexpected keys' do
  subject(:schema) do
    Dry::Schema.define do
      config.validate_keys = true

      required(:name).filled(:string)

      required(:address).hash do
        required(:city).filled(:string)
        required(:zipcode).filled(:string)
      end

      required(:roles).array(:hash) do
        required(:name).filled(:string)
      end
    end
  end

  it 'adds error messages about unexpected keys' do
    input = {
      foo: 'unexpected',
      name: 'Jane',
      address: { bar: 'unexpected', city: 'NYC', zipcode: '1234' },
      roles: [{ name: 'admin' }, { name: 'editor', foo: 'unexpected' }]
    }

    expect(schema.(input).errors.to_h)
      .to eql(
        foo: ['is not allowed'],
        address: { bar: ['is not allowed'] },
        roles: { 1 => { foo: ['is not allowed'] } }
      )
  end
end
