# frozen_string_literal: true

require 'dry/schema/messages/i18n'

RSpec.describe Dry::Schema::Messages::I18n do
  context 'with default config' do
    subject(:messages) do
      Dry::Schema::Messages::I18n.build
    end

    describe '#lookup' do
      it 'returns lookup result' do
        result = messages.lookup(:filled?, {}, path: [:name])

        expect(result).to eql(
          text: 'must be filled',
          meta: {}
        )
      end
    end

    describe '#translate' do
      it 'returns translated string' do
        expect(messages.translate(:or)).to eql('or')
      end
    end
  end

  context 'with custom top-level namespace config' do
    subject(:messages) do
      Dry::Schema::Messages::I18n.build(top_namespace: 'my_app')
    end

    describe '#lookup' do
      it 'returns lookup result' do
        result = messages.lookup(:filled?, {}, path: [:name])

        expect(result).to eql(
          text: 'must be filled',
          meta: {}
        )
      end
    end

    describe '#translate' do
      it 'returns translated string' do
        expect(messages.translate(:or)).to eql('or')
      end
    end
  end
end
