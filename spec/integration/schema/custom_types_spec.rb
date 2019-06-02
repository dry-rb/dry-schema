# frozen_string_literal: true

RSpec.describe 'Registering custom types' do
  let(:klass) do
    Test::Kontainer = type_container

    class Test::CustomTypeSchema < Dry::Schema::Params
      define do
        config.types = Test::Kontainer

        required(:email).filled(:string)
        required(:age).filled(:trimmed_string)
      end
    end
  end

  subject(:schema) { klass.new.call(params) }

  let(:type_container) { Dry::Schema::TypeContainer.new  }

  let(:trimmed_string) do
    Types::Strict::String.constructor(&:strip).constructor(&:downcase)
  end

  let(:params) {
    {
      email: 'some@body.abc',
      age: '  I AM NOT THAT OLD '
    }
  }

  context 'types not registered' do
    it 'raises exception that nothing is registered with the key' do
      expect { subject }.to raise_exception(Dry::Container::Error)
    end
  end

  context 'custom type is registered' do
    before do
      type_container.register('trimmed_string', trimmed_string)
      type_container.register('params.trimmed_string', trimmed_string)
    end

    it 'does not raise any exceptions' do
      expect { subject }.not_to raise_exception
    end

    it 'coerces the type' do
      expect(subject[:age]).to eql('i am not that old')
    end
  end
end
