# frozen_string_literal: true

RSpec.describe "Macros #filled" do
  describe "with a constructor type" do
    subject(:schema) do
      Dry::Schema.Params do
        required(:foo).filled(Test::StrippedString)
      end
    end

    before do
      Test::StrippedString = Types::String.constructor(&:strip)
    end

    it "applies constructor before applying filled?" do
      result = schema.(foo: "   ")

      expect(result.to_h).to eql(foo: "")
      expect(result.errors).to eql(foo: ["must be filled"])
    end
  end
end
