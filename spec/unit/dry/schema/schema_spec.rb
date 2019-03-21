# frozen_string_literal: true

require 'dry/schema/messages/i18n'

RSpec.describe Dry::Schema do
  describe '.messages' do
    context 'with default setting' do
      let(:schema) do
        Dry::Schema.define {}
      end

      it 'returns default yaml messages' do
        expect(schema.message_compiler.messages)
          .to be_instance_of(Dry::Schema::Messages::YAML)
      end
    end

    context 'with i18n setting' do
      let(:schema) do
        Dry::Schema.define { configure { config.messages.backend = :i18n } }
      end

      it 'returns default i18n messages' do
        expect(schema.message_compiler.messages)
          .to be_instance_of(Dry::Schema::Messages::I18n)
      end
    end

    context 'with an invalid setting' do
      let(:schema) do
        Dry::Schema.define { configure { config.messages.backend = :oops } }
      end

      it 'returns default i18n messages' do
        expect { schema }.to raise_error(RuntimeError, /oops/)
      end
    end
  end
end
