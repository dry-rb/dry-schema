# frozen_string_literal: true

RSpec.describe Dry::Schema, "defining a schema with json coercion" do
  subject(:schema) do
    Dry::Schema.JSON do
      required(:email).value(:string).filled

      required(:age).maybe(:integer).maybe(:integer, gt?: 18)

      required(:address).value(:hash).hash do
        required(:city).value(:string).filled
        required(:street).value(:string).filled

        required(:loc).value(:hash).hash do
          required(:lat).filled(:float)
          required(:lng).filled(:float)
        end
      end

      optional(:phone_number).maybe(:integer, gt?: 0)
    end
  end

  describe "#messages" do
    it "returns compiled error messages" do
      result = schema.("email" => "", "age" => 19)

      expect(result.messages).to eql(
        email: ["must be filled"],
        address: ["is missing", "must be a hash"]
      )

      expect(result.output).to eql(email: "", age: 19)
    end

    it "returns hints for nested data" do
      result = schema.(
        "email" => "jane@doe.org",
        "age" => 19,
        "address" => {
          "city" => "",
          "street" => "Street 1/2",
          "loc" => {"lat" => "123.456", "lng" => ""}
        }
      )

      expect(result.messages).to eql(
        address: {
          loc: {lat: ["must be a float"], lng: ["must be a float"]},
          city: ["must be filled"]
        }
      )
    end
  end

  describe "#call" do
    it "passes when attributes are valid" do
      result = schema.(
        "email" => "jane@doe.org",
        "age" => 19,
        "address" => {
          "city" => "NYC",
          "street" => "Street 1/2",
          "loc" => {"lat" => 123.456, "lng" => 456.123}
        }
      )

      expect(result).to be_success

      expect(result.output).to eql(
        email: "jane@doe.org", age: 19,
        address: {
          city: "NYC", street: "Street 1/2",
          loc: {lat: 123.456, lng: 456.123}
        }
      )
    end

    it "validates presence of an email and min age value" do
      result = schema.("email" => "", "age" => 18)

      expect(result.messages).to eql(
        address: ["is missing", "must be a hash"],
        age: ["must be greater than 18"],
        email: ["must be filled"]
      )
    end

    it "handles optionals" do
      result = schema.(
        "email" => "jane@doe.org",
        "age" => 19,
        "phone_number" => 12,
        "address" => {
          "city" => "NYC",
          "street" => "Street 1/2",
          "loc" => {"lat" => 123.456, "lng" => 456.123}
        }
      )

      expect(result).to be_success

      expect(result.output).to eql(
        email: "jane@doe.org", age: 19, phone_number: 12,
        address: {
          city: "NYC", street: "Street 1/2",
          loc: {lat: 123.456, lng: 456.123}
        }
      )
    end

    context "empty strings" do
      subject(:schema) do
        Dry::Schema.JSON do
          required(:name).maybe(:string)
        end
      end

      it "keeps strings when maybe macro is used" do
        result = schema.(name: "")

        expect(result).to be_success
        expect(result.to_h).to eql(name: "")
      end
    end
  end
end
