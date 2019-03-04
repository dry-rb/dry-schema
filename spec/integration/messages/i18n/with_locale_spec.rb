# frozen_string_literal: true

require 'dry/schema'
require 'dry/schema/messages/i18n'

RSpec.describe 'I18n validation messages / using I18n.with_locale' do
  subject(:schema) do
    Dry::Schema.Params do
      config.messages = :i18n
      config.namespace = :user

      required(:name).filled(:string)
    end
  end

  let(:result) { schema.(name: '') }
  let(:expected) { ['заполните это поле'] }

  around do |example|
    I18n.available_locales = %i[en ru]
    I18n.locale = I18n.default_locale = :en

    I18n.backend.store_translations(:en,
      dry_schema: { errors: { user: { rules: { name: { filled?: 'must be filled' } } } } }
    )

    I18n.backend.store_translations(:ru,
      dry_schema: { errors: { user: { rules: { name: { filled?: 'заполните это поле' } } } } }
    )

    I18n.with_locale(:ru) { example.run }
  end

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
