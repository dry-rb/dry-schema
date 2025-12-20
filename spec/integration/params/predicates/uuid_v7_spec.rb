# frozen_string_literal: true

RSpec.describe "Predicates: uuid_v7?" do
  subject(:schema) do
    Dry::Schema.Params do
      required(:uuid).value(:string, :uuid_v7?)
    end
  end

  it "passes with valid input" do
    expect(schema.(uuid: "017F22E2-79B0-7CC3-98C4-DC0C0C07398F")).to be_success
  end

  it "fails with invalid input" do
    expect(schema.(uuid: "not-uuid").errors.to_h).to eql(uuid: ["is not a valid UUID"])
  end
end
