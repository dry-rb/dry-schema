# frozen_string_literal: true

require 'dry/schema/messages/i18n'

RSpec.describe Dry::Schema, 'with localized messages' do
  before do
    I18n.config.available_locales = %i[en pl]
  end

  describe 'defining schema' do
    context 'without a namespace' do
      subject(:schema) do
        Dry::Schema.define do
          config.messages.backend = :i18n
          config.messages.load_paths = %w[en pl]
            .map { |l| SPEC_ROOT.join("fixtures/locales/#{l}.yml") }

          required(:email).value(:filled?)
        end
      end

      describe '#messages' do
        it 'returns localized error messages' do
          expect(schema.(email: '').messages(locale: :pl)).to eql(
            email: ['Proszę podać adres email']
          )
        end
      end
    end

    context 'with a namespace' do
      subject(:schema) do
        Dry::Schema.define do
          config.messages.backend = :i18n
          config.messages.namespace = :user
          config.messages.load_paths = %w[en pl]
            .map { |l| SPEC_ROOT.join("fixtures/locales/#{l}.yml") }

          required(:email).value(:filled?)
        end
      end

      describe '#messages' do
        it 'returns localized error messages' do
          expect(schema.(email: '').messages(locale: :pl)).to eql(
            email: ['Hej user! Dawaj ten email no!']
          )
        end
      end
    end
  end
end
