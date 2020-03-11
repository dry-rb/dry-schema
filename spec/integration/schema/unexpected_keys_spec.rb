# frozen_string_literal: true

RSpec.describe Dry::Schema, "unexpected keys" do
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
        required(:expires_at).value(:date)
      end
    end
  end

  it "adds error messages about unexpected keys" do
    input = {
      foo: "unexpected",
      name: "Jane",
      address: {bar: "unexpected", city: "NYC", zipcode: "1234"},
      roles: [
        {name: "admin", expires_at: Date.today},
        {name: "editor", foo: "unexpected", expires_at: Date.today}
      ]
    }

    expect(schema.(input).errors.to_h)
      .to eql(
        foo: ["is not allowed"],
        address: {bar: ["is not allowed"]},
        roles: {1 => {foo: ["is not allowed"]}}
      )
  end
end
