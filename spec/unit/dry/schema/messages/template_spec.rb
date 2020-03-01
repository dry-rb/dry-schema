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

  subject(:template) do
    Dry::Schema::Messages::Template.new(
      messages: messages,
      key: '%<locale>s.dry_schema.errors.neato?',
      options: {
        name: 'Alice',
        locale: :en
      }
    )
  end

  describe '#data' do
    it 'delegates to the message backend' do
      expect(template.data(adjective: 'rad', ignored: 'param'))
        .to eq(adjective: 'rad', name: 'Alice')
    end
  end

  describe '#call' do
    it 'delegates to the message backend' do
      expect(template.(name: 'Alice', adjective: 'rad')).to eq('Alice is awesome and rad')
    end
  end
end
