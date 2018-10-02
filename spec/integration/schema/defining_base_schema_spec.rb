RSpec.describe 'Defining base schema class' do
  subject(:schema) do
    Dry::Schema.define(parent: parent) do
      required(:email).filled
    end
  end

  let(:parent) do
    Dry::Schema.define do
      required(:name).filled
    end
  end

  it 'inherits rules' do
    expect(schema.(name: '').errors).to eql(name: ['must be filled'], email: ['is missing'])
  end
end
