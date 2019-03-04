# frozen_string_literal: true

RSpec.describe 'Defining base schema class' do
  subject(:form) do
    Dry::Schema.Params(parent: parent) do
      required(:email).filled
    end
  end

  let(:parent) do
    Dry::Schema.Params do
      required(:name).filled
    end
  end

  it 'inherits rules' do
    expect(form.(name: '').errors).to eql(name: ['must be filled'], email: ['is missing'])
  end
end
