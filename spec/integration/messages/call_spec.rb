# frozen_string_literal: true

RSpec.describe Dry::Schema::Messages::Abstract, '#call' do
  shared_context 'resolving templates' do
    subject(:messages) do
      message_compiler.messages
    end

    let(:message_compiler) do
      schema.message_compiler
    end

    let(:cache) do
      messages.cache
    end

    before do
      schema.({}).errors
      schema.(name: {}).errors
      schema.(name: 12).errors
      schema.(name: 'foo').errors
      schema.(name: 'bar').errors
    end

    def template(predicate, opts = {})
      messages[predicate, { path: :name, message_type: :failure, **opts }]
    end

    it 'caches min amount of templates' do
      expect(cache.size).to be(4)
    end

    it 'caches templates' do
      expect(template(:key?, arg_type: Array, val_type: Hash))
        .to be(template(:key?, arg_type: Array, val_type: Hash))
    end
  end

  context 'YAML' do
    include_context 'resolving templates' do
      let(:schema) do
        Dry::Schema.define do
          required(:name).value(:string, min_size?: 10)
        end
      end
    end
  end

  context 'i18n' do
    include_context 'resolving templates' do
      let(:schema) do
        Dry::Schema.define do
          config.messages.backend = :i18n

          required(:name).value(:string, min_size?: 10)
        end
      end
    end
  end
end
