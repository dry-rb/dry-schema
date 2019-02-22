RSpec.describe 'Defining base schema class' do
  subject(:schema) do
    Dry::Schema.define(parent: parent) do
      required(:email).filled
      required(:age).filled
    end
  end

  let(:parent) do
    Dry::Schema.define do
      optional(:email).filled
      required(:name).filled
    end
  end

  it 'inherits rules' do
    expect(schema.(name: '', email: 'jane@doe.org').errors).to eql(name: ['must be filled'], age: ['is missing'])
  end

  it 'overrides parent rules' do
    expect(schema.(age: 21, name: 'Jane').errors).to eql(email: ['is missing'])
  end
end
