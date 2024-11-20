# frozen_string_literal: true

RSpec.describe "Predicates: uuid_v5?" do
  subject(:schema) do
    Dry::Schema.Params do
      required(:uuid).value(:string, :uuid_v5?)
    end
  end

  it "passes with valid input" do
    expect(schema.(uuid: "601d90d0-8611-502d-b49b-86c0779b6159")).to be_success
  end

  it "fails with invalid input" do
    expect(schema.(uuid: "not-uuid").errors.to_h).to eql(uuid: ["is not a valid UUID"])
  end
end
