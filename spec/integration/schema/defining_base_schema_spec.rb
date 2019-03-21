# frozen_string_literal: true

RSpec.describe 'Defining base schema class' do
  subject(:schema) do
    Dry::Schema.define(parent: parent) do
      required(:email).filled
      required(:age).filled
    end
  end

  let(:parent) do
    Dry::Schema.define do
      configure do |config|
        config.messages.backend = :i18n
      end

      optional(:email).filled
      required(:name).filled
    end
  end

  it 'inherits rules' do
    expect(schema.(name: '', email: 'jane@doe.org').errors).to eql(name: ['must be filled'], age: ['is missing'])
  end

  it 'overrides parent rules' do
    expect(schema.(age: 21, name: 'Jane').errors).to eql(email: ['is missing'])
  end

  it 'inherits config' do
    expect(schema.config.messages.backend).to eql(:i18n)
  end

  context 'when child schema defines config' do
    subject(:schema) do
      Dry::Schema.define(parent: parent) do
        configure do |config|
          config.messages.backend = :yaml
        end
      end
    end

    it 'overrides parent config' do
      expect(schema.config.messages.backend).to eql(:yaml)
    end
  end
end
