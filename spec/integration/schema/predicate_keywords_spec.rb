# frozen_string_literal: true

RSpec.describe "Predicate keywords in the DSL" do
  subject(:schema) do
    Dry::Schema.Params do
      required(:password).filled(:string, min_size: 8)
      required(:code).value(:string, size?: 4)
    end
  end

  it "accepts predicate names without a question mark" do
    expect(schema.(password: "short", code: "abc").errors.to_h).to eql(
      password: ["size cannot be less than 8"],
      code: ["length must be 4"]
    )
  end

  it "passes valid input" do
    expect(schema.(password: "long enough", code: "abcd")).to be_success
  end

  it "raises for an unknown predicate" do
    expect { Dry::Schema.define { required(:age).value(oops: 1) } }
      .to raise_error(ArgumentError, "oops? predicate is not defined")
  end
end
