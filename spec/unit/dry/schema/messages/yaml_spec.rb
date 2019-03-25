# frozen_string_literal: true

require 'dry/schema/messages/yaml'

RSpec.describe Dry::Schema::Messages::YAML do
  describe '#[]' do
    context 'with default config' do
      subject(:messages) do
        Dry::Schema::Messages::YAML.build
      end

      it 'returns message template' do
        expect(messages[:filled?, path: [:name]].()).to eql('must be filled')
      end
    end

    context 'with custom top-level namespace config' do
      subject(:messages) do
        Dry::Schema::Messages::YAML.build(top_namespace: 'my_app')
      end

      it 'returns message template' do
        expect(messages[:filled?, path: [:name]].()).to eql('must be filled')
      end
    end
  end
end
