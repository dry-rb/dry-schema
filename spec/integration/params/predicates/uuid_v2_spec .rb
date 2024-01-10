# frozen_string_literal: true

RSpec.describe "Predicates: uuid_v2?" do
  subject(:schema) do
    Dry::Schema.Params do
      required(:uuid).value(:string, :uuid_v2?)
    end
  end

  it "passes with valid input" do
    expect(schema.(uuid: '000003e8-afff-21ee-a300-325096b39f47')).to be_success
  end

  it "fails with invalid input" do
    expect(schema.(uuid: "not-uuid").errors.to_h).to eql(uuid: ["is not a valid UUID"])
  end
end
