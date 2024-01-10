# frozen_string_literal: true

RSpec.describe "Predicates: uuid_v1?" do
  subject(:schema) do
    Dry::Schema.Params do
      required(:uuid).value(:string, :uuid_v1?)
    end
  end

  it "passes with valid input" do
    expect(schema.(uuid: '2e14d58e-afff-11ee-a506-0242ac120002')).to be_success
  end

  it "fails with invalid input" do
    expect(schema.(uuid: "not-uuid").errors.to_h).to eql(uuid: ["is not a valid UUID"])
  end
end
