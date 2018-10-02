require 'dry/schema/config'

RSpec.describe Dry::Schema::Config do
  subject(:config) do
    Dry::Schema::Config.new
  end

  describe '#messages' do
    it 'returns default value' do
      expect(config.messages).to be(:yaml)
    end

    it 'returns overridden value' do
      config.configure do |config|
        config.messages = :i18n
      end

      expect(config.messages).to be(:i18n)
    end
  end
end
