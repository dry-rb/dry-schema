# frozen_string_literal: true

RSpec.describe "Schema descriptions" do
  subject(:schema) do
    Dry::Schema.define do
      required(:first_name).filled(:string).description("First name of the user")
      optional(:age).filled(:integer).description("Age of the user")
      required(:address).description("The shipping address").hash do
        required(:street).filled(:string).description("Street address")
        optional(:city).filled(:string).description("City name")
        optional(:zipcode).maybe(:string).description("Postal code")
      end
    end
  end

  it "stores descriptions in type meta" do
    expect(schema.types[:first_name].meta[:description]).to eql("First name of the user")
    expect(schema.types[:age].meta[:description]).to eql("Age of the user")
    expect(schema.types[:address].meta[:description]).to eql("The shipping address")
  end

  it "validates normally" do
    result = schema.(first_name: "John", age: 30, address: {street: "123 Main St", city: "NYC"})
    expect(result).to be_success
  end

  context "with arrays" do
    subject(:schema) do
      Dry::Schema.define do
        required(:tags).array(:string).description("List of tags")
      end
    end

    it "stores description on array type" do
      expect(schema.types[:tags].meta[:description]).to eql("List of tags")
    end
  end

  context "with json_schema extension" do
    before do
      Dry::Schema.load_extensions(:json_schema)
    end

    it "includes descriptions in JSON schema output" do
      json_schema = schema.json_schema

      expect(json_schema[:properties][:first_name][:description]).to eql("First name of the user")
      expect(json_schema[:properties][:age][:description]).to eql("Age of the user")
      expect(json_schema[:properties][:address][:description]).to eql("The shipping address")
    end

    it "includes nested descriptions in JSON schema output" do
      json_schema = schema.json_schema
      address_props = json_schema[:properties][:address][:properties]

      expect(address_props[:street][:description]).to eql("Street address")
      expect(address_props[:city][:description]).to eql("City name")
      expect(address_props[:zipcode][:description]).to eql("Postal code")
    end
  end
end
