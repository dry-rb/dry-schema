# frozen_string_literal: true

RSpec.describe 'Defining a schema with multiple parents' do
  subject(:form) do
    Dry::Schema.Params(parent: [parent1, parent2]) do
      required(:name).filled(:string)
    end
  end

  let(:parent1) do
    Dry::Schema.Params do
      required(:email).filled(:string)

      after(:rule_applier) do |result|
        result.to_h[:foo] = 'foo'
      end
    end
  end

  let(:parent2) do
    Dry::Schema.Params do
      required(:age).filter(:filled?).value(:integer)

      after(:rule_applier) do |result|
        result.to_h[:bar] = 'bar'
      end
    end
  end

  it 'inherits rules' do
    expect(form.(name: '', age: '').errors.to_h)
      .to eql(email: ['is missing'], age: ['must be filled'], name: ['must be filled'])
  end

  it 'inherits callbacks' do
    expect(form.(name: '').to_h).to eql(name: '', foo: 'foo', bar: 'bar')
  end
end
