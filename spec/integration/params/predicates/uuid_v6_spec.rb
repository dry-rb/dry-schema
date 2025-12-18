# frozen_string_literal: true

RSpec.describe "Predicates: uuid_v6?" do
  subject(:schema) do
    Dry::Schema.Params do
      required(:uuid).value(:string, :uuid_v6?)
    end
  end

  it "passes with valid input" do
    expect(schema.(uuid: "1EC9414C-232A-6B00-B3C8-9E6BDECED846")).to be_success
  end

  it "fails with invalid input" do
    expect(schema.(uuid: "not-uuid").errors.to_h).to eql(uuid: ["is not a valid UUID"])
  end
end
