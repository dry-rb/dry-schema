# frozen_string_literal: true

RSpec.describe Dry::Schema do
  describe "defining schema with optional keys and value rules" do
    subject(:schema) do
      Dry::Schema.define do
        optional(:email).value(:string, :filled?)

        required(:address).hash do
          required(:city).value(:string, :filled?)
          required(:street).value(:string, :filled?)

          optional(:phone_number).value([:nil, :string])
        end
      end
    end

    describe "#call" do
      it "skips rules when key is not present" do
        expect(schema.(address: {city: "NYC", street: "Street 1/2"})).to be_success
      end

      it "applies rules when key is present" do
        expect(schema.(email: "")).to_not be_success
      end
    end
  end

  describe "defining schema with optional keys without value rules" do
    subject(:schema) do
      Dry::Schema.define do
        required(:name).filled(:string)
        optional(:login).filled(:any)
      end
    end

    it "skips key rules" do
      result = schema.(name: "test")

      expect(result.to_h).to eql(name: "test")
      expect(result).to be_success
    end
  end

  describe "defining schema with optional key that can be an array with hashes" do
    subject(:schema) do
      Dry::Schema.define do
        optional(:contacts).array(:hash) do
          required(:name).filled(:string)
        end
      end
    end

    it "produces correct errors when array has an empty element" do
      expect(schema.(contacts: [{}]).errors)
        .to eql(contacts: {0 => {name: ["is missing"]}})
    end

    it "produces correct errors when array has an invalid element" do
      expect(schema.(contacts: [{name: ""}]).errors)
        .to eql(contacts: {0 => {name: ["must be filled"]}})
    end
  end
end
