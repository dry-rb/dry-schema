RSpec.describe Dry::Schema, 'pre-coercion input rules' do
  context 'with required keys' do
    subject(:schema) do
      Dry::Schema.define do
        required(:age).filter(format?: /\d+/).value(:int, gt?: 18)
      end
    end

    it 'uses pre-coercion rules' do
      expect(schema.call(age: 'foo').errors).to eql(age: ['is in invalid format'])
    end
  end

  context 'with optional keys' do
    subject(:schema) do
      Dry::Schema.define do
        optional(:age).filter(format?: /\d+/).value(:int, gt?: 18)
      end
    end

    it 'uses pre-coercion rules' do
      expect(schema.call(age: 'foo').errors).to eql(age: ['is in invalid format'])
    end

    it 'skips pre-coercion when key is missing' do
      expect(schema.call({}).errors).to be_empty
    end
  end
end
