RSpec.describe Dry::Schema::JSON, '#to_open_api' do
  before do
    Dry::Schema.load_extensions(:open_api)
  end

  subject(:schema) do
    Dry::Schema.JSON do
      required(:email).filled(:string)
      required(:age).filled(:integer)
    end
  end

  let(:open_api_schema) do
    { properties: {
        email: {
          type: "string"
        },
        age: {
          type: "integer"
        }
      } }
  end

  it 'returns an Open API properties hash' do
    expect(schema.to_open_api).to eql(open_api_schema)
  end
end
