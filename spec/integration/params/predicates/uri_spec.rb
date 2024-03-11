# frozen_string_literal: true

RSpec.describe "Predicates: uri?" do
  subject(:schema) do
    Dry::Schema.Params do
      required(:uri) { str? & uri?(:https) }
    end
  end

  it "passes with valid input" do
    expect(schema.(uri: "https://www.example.com")).to be_success
  end

  it "fails with invalid input" do
    expect(schema.(uri: "not-a-uri").errors.to_h).to eql(uri: ["is not a valid URI"])
  end
end
