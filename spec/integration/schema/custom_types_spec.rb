# frozen_string_literal: true

RSpec.describe 'Registering custom types' do
  let(:container_without_types) { Dry::Schema::TypeContainer.new }
  let(:container_with_types) do
    Dry::Schema::TypeContainer.new
  end

  let(:params) do
    {
      email: 'some@body.abc',
      age: '  I AM NOT THAT OLD '
    }
  end

  before do
    container_with_types.register(
      'params.trimmed_string',
      Types::Strict::String.constructor(&:strip).constructor(&:downcase)
    )

    stub_const('ContainerWithoutTypes', container_without_types)
    stub_const('ContainerWithTypes', container_with_types)
  end

  context 'class-based definition' do
    subject(:schema) { klass.new.call(params) }

    context 'custom type is not registered' do
      let(:klass) do
        class Test::CustomTypeSchema < Dry::Schema::Params
          define do
            config.types = ContainerWithoutTypes

            required(:email).filled(:string)
            required(:age).filled(:trimmed_string)
          end
        end
      end

      it 'raises exception that nothing is registered with the key' do
        expect { subject }.to raise_exception(Dry::Container::Error)
      end
    end

    context 'custom type is registered' do
      let(:klass) do
        class Test::CustomTypeSchema < Dry::Schema::Params
          define do
            config.types = ContainerWithTypes

            required(:email).filled(:string)
            required(:age).filled(:trimmed_string)
          end
        end
      end

      it 'does not raise any exceptions' do
        expect { subject }.not_to raise_exception
      end

      it 'coerces the type' do
        expect(subject[:age]).to eql('i am not that old')
      end
    end
  end

  context 'DSL-based definition' do
    subject(:schema) { schema_object.call(params) }

    context 'custom type is not registered' do
      let(:schema_object) do
        Dry::Schema.Params do
          config.types = ContainerWithoutTypes

          required(:email).filled(:string)
          required(:age).filled(:trimmed_string)
        end
      end

      it 'raises exception that nothing is registered with the key' do
        expect { subject }.to raise_exception(Dry::Container::Error)
      end
    end

    context 'custom type is registered' do
      let(:schema_object) do
        Dry::Schema.Params do
          config.types = ContainerWithTypes

          required(:email).filled(:string)
          required(:age).filled(:trimmed_string)
        end
      end

      it 'does not raise any exceptions' do
        expect { subject }.not_to raise_exception
      end

      it 'coerces the type' do
        expect(subject[:age]).to eql('i am not that old')
      end
    end
  end
end
