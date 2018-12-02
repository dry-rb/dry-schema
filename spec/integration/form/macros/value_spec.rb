RSpec.describe 'Schema / Form / Macros / #value' do
  describe "with a type spec" do
    subject(:schema) do
      Dry::Schema.form do
        required(:age).value(:int, gt?: 18)
      end
    end

    it "coerces input" do
      expect(schema.(age: "312").to_h[:age]).to be(312)
    end
  end
end