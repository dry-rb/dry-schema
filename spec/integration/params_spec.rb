# frozen_string_literal: true

require "dry/schema"

RSpec.describe Dry::Schema, ".Params" do
  subject(:params) do
    Dry::Schema.Params do
      required(:address).hash do
        required(:street).filled(:string)
        required(:zipcode).filled(:string)
        required(:city).filled(:string)
      end
    end
  end

  let(:input) do
    {"address" => {"street" => "Street 1/2", "zipcode" => "12345", city: "Krakow"}}
  end

  it "coerces stringified hash input to a symbolized hash" do
    expect(params.(input).to_h)
      .to eql(address: {street: "Street 1/2", zipcode: "12345", city: "Krakow"})
  end

  it "does not crash when defined nested hash is not a hash" do
    expect(params.(address: nil).to_h).to eql(address: nil)
    expect(params.(address: []).to_h).to eql(address: [])
    expect(params.(address: "foo").to_h).to eql(address: "foo")
  end
end
