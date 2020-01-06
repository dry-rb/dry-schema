# frozen_string_literal: true

require 'dry/schema'
require 'dry/schema/messages/i18n'

RSpec.describe 'I18n validation messages / using I18n.with_locale' do
  around do |ex|
    I18n.available_locales = %i[en ru]
    I18n.locale = I18n.default_locale = :en
    ex.run
  end

  context 'with current locale' do
    subject(:schema) do
      Dry::Schema.Params do
        config.messages.backend = :i18n
        config.messages.namespace = :user

        required(:name).filled(:string)
      end
    end

    around do |example|
      I18n.backend.store_translations(:en,
                                      dry_schema: { errors: { user: { rules: { name: { filled?: 'must be filled' } } } } })

      I18n.backend.store_translations(:ru,
                                      dry_schema: { errors: { user: { rules: { name: { filled?: 'заполните это поле' } } } } })

      I18n.with_locale(:ru) { example.run }
    end

    let(:result) { schema.(name: '') }

    let(:expected) { ['заполните это поле'] }

    it 'uses correct locale without providing :locale option for errors' do
      expect(result.errors[:name]).to eql(expected)
    end

    it 'uses provided :locale option for errors' do
      expect(result.errors(locale: I18n.locale)[:name]).to eql(expected)
    end

    it 'uses correct locale without providing :locale option for messages' do
      expect(result.messages[:name]).to eql(expected)
    end

    it 'uses provided :locale option for messages' do
      expect(result.messages(locale: I18n.locale)[:name]).to eql(expected)
    end
  end

  context 'caching' do
    shared_examples_for 'caching behavior' do
      it 'uses current locale in cache key and returns different messages for different locales' do
        en_message = I18n.with_locale(:en) { schema.(name: '').errors[:name] }
        ru_message = I18n.with_locale(:ru) { schema.(name: '').errors[:name] }

        expect(en_message).to eql(['must be filled'])
        expect(ru_message).to eql(['заполните это поле'])
      end
    end

    context 'without namespace' do
      subject(:schema) do
        Dry::Schema.Params do
          config.messages.backend = :i18n

          required(:name).filled(:string)
        end
      end

      before do
        I18n.backend.store_translations(:en,
                                        dry_schema: { errors: { rules: { name: { filled?: 'must be filled' } } } })

        I18n.backend.store_translations(:ru,
                                        dry_schema: { errors: { rules: { name: { filled?: 'заполните это поле' } } } })
      end

      include_examples 'caching behavior'
    end

    context 'with namespace' do
      subject(:schema) do
        Dry::Schema.Params do
          config.messages.backend = :i18n
          config.messages.namespace = :user

          required(:name).filled(:string)
        end
      end

      before do
        I18n.backend.store_translations(:en,
                                        dry_schema: { errors: { user: { rules: { name: { filled?: 'must be filled' } } } } })

        I18n.backend.store_translations(:ru,
                                        dry_schema: { errors: { user: { rules: { name: { filled?: 'заполните это поле' } } } } })
      end

      include_examples 'caching behavior'
    end
  end
end
