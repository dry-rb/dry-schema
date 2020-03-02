# frozen_string_literal: true

require 'dry/schema/messages/template'
require 'dry/schema/messages/yaml'

RSpec.describe Dry::Schema::Messages::Template do
  let(:messages) do
    Dry::Schema::Messages::YAML.new.merge(
      stringify_keys(
        en: {
          dry_schema: {
            errors: {
              neato?: '%{name} is awesome and %{adjective}'
            }
          }
        }
      )
    )
  end

  let(:valid_template) do
    Dry::Schema::Messages::Template.new(
      messages: messages,
      key: '%<locale>s.dry_schema.errors.neato?',
      options: {
        name: 'Alice',
        locale: :en
      }
    )
  end

  let(:broken_template) do
    Dry::Schema::Messages::Template.new(
      messages: messages,
      key: 'this does not exist',
      options: {}
    )
  end

  describe '#data' do
    it 'delegates to the message backend' do
      expect(valid_template.data(adjective: 'rad', ignored: 'param'))
        .to eq(adjective: 'rad', name: 'Alice')
    end

    it 'raises a KeyError when the key does not exist' do
      expect { broken_template.data }.to raise_error(KeyError)
    end
  end

  describe '#call' do
    it 'delegates to the message backend' do
      expect(valid_template.(name: 'Alice', adjective: 'rad')).to eq('Alice is awesome and rad')
    end

    it 'raises a KeyError when the key does not exist' do
      expect { broken_template.call }.to raise_error(KeyError)
    end
  end
end
