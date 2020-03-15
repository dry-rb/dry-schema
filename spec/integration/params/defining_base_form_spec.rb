# frozen_string_literal: true

RSpec.describe "Defining base schema class" do
  subject(:form) do
    Dry::Schema.Params(parent: parent) do
      required(:name).filled(:string)
    end
  end

  let(:parent) do
    Dry::Schema.Params do
      required(:email).filled(:string)
      required(:age).filter(:any, :filled?).value(:integer)
    end
  end

  it "inherits rules" do
    expect(form.(name: "", age: "").errors.to_h)
      .to eql(email: ["is missing"], age: ["must be filled"], name: ["must be filled"])
  end
end
