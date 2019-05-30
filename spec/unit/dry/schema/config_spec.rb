# frozen_string_literal: true

require 'dry/schema/config'

RSpec.describe Dry::Schema::Config do
  subject(:config) do
    Dry::Schema::Config.new
  end

  describe '#messages' do
    it 'returns default value' do
      expect(config.messages.backend).to be(:yaml)
    end

    it 'returns overridden value' do
      config.messages.backend = :i18n

      expect(config.messages.backend).to be(:i18n)
    end
  end

  describe '#predicates' do
    it 'returns configured predicates registry' do
      expect(config.predicates).to be_instance_of(Dry::Schema::PredicateRegistry)
    end
  end

  describe '#finalize!' do
    it 'finalizes the config' do
      config.finalize!

      expect(config).to be_frozen
    end
  end
end
