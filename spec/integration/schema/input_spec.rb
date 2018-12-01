RSpec.describe Dry::Schema, 'pre-coercion input rules' do
  subject(:schema) do
    Dry::Schema.define do
      required(:age).filter(format?: /\d+/).value(:int, gt?: 18)
    end
  end

  it 'uses pre-coercion rules' do
    expect(schema.(age: 'foo').errors).to eql(age: ['is in invalid format'])
  end
end
