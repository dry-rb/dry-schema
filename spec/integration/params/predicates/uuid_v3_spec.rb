# frozen_string_literal: true

RSpec.describe "Predicates: uuid_v3?" do
  subject(:schema) do
    Dry::Schema.Params do
      required(:uuid).value(:string, :uuid_v3?)
    end
  end

  it "passes with valid input" do
    expect(schema.(uuid: "1d955abe-9522-33d5-a788-a1b186b163dc")).to be_success
  end

  it "fails with invalid input" do
    expect(schema.(uuid: "not-uuid").errors.to_h).to eql(uuid: ["is not a valid UUID"])
  end
end
