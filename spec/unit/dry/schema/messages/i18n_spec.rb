# frozen_string_literal: true

require 'dry/schema/messages/i18n'

RSpec.describe Dry::Schema::Messages::I18n do
  context 'with default config' do
    subject(:messages) do
      Dry::Schema::Messages::I18n.build
    end

    describe '#[]' do
      it 'returns message template' do
        expect(messages[:filled?, path: [:name]].()).to eql('must be filled')
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

    describe '#[]' do
      it 'returns message template' do
        expect(messages[:filled?, path: [:name]].()).to eql('must be filled')
      end
    end

    describe '#translate' do
      it 'returns translated string' do
        expect(messages.translate(:or)).to eql('or')
      end
    end
  end
end
