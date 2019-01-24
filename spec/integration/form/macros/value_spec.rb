RSpec.describe 'Schema / Form / Macros / #value' do
  describe "with a type spec as a symbol" do
    subject(:schema) do
      Dry::Schema.form do
        required(:age).value(:int, gt?: 18)
      end
    end

    it "coerces input" do
      expect(schema.(age: "312").to_h[:age]).to be(312)
    end
  end

  describe "with a type spec as a type object" do
    subject(:schema) do
      Dry::Schema.form do
        required(:age).value(Dry::Types['coercible.int'], gt?: 18)
      end
    end

    it "coerces input" do
      expect(schema.(age: "312").to_h[:age]).to be(312)
    end
  end

  describe "with a type spec as an array" do
    subject(:schema) do
      Dry::Schema.form do
        required(:age).value([:nil, :int]) { none? | (int? & gt?(18)) }
      end
    end

    it "coerces input" do
      expect(schema.(age: nil).to_h[:age]).to be_nil
      expect(schema.(age: "312").to_h[:age]).to be(312)
    end
  end
end