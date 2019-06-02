# frozen_string_literal: true

RSpec.describe 'Registering custom types' do
  subject(:schema) do
    Dry::Schema.define do
      # config.types = types

      required(:email).filled(:string)
      required(:age).filled(:trimmed_string)
    end
  end

  let(:trimmed_string) do
    Types::Strict::String.constructor(&:trim).constructor(&:downcase)
  end

  let(:types) do
    Dry::Schema::TypeContainer.new
  end

  let(:params) {
    {
      email: 'some@body.abc',
      age: '  I AM NOT THAT OLD '
    }
  }

  context 'types not registered' do
    before do
      types.register('missing_string', trimmed_string)
    end

    it 'raises exception that nothing is registered with the key' do
      expect { subject }.to raise_exception(Dry::Container::Error)
    end
  end

  context 'custom type is registered' do
    it 'does not raise any exceptions' do
      expect { subject }.not_to raise_exception
    end

    it 'coerces the type' do
      expect(subject[:age]).to eql('I AM NOT THAT OLD')
    end
  end
end
