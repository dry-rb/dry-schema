# frozen_string_literal: true

RSpec.describe "Predicates: uuid_v8?" do
  subject(:schema) do
    Dry::Schema.Params do
      required(:uuid).value(:string, :uuid_v8?)
    end
  end

  it "passes with valid input" do
    expect(schema.(uuid: "320C3D4D-CC00-875B-8EC9-32D5F69181C0")).to be_success
  end

  it "fails with invalid input" do
    expect(schema.(uuid: "not-uuid").errors.to_h).to eql(uuid: ["is not a valid UUID"])
  end
end
