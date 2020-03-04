RSpec.describe Dry::Schema, 'callbacks' do
  context 'top-level' do
    subject(:schema) do
      Dry::Schema.define do
        optional(:name).maybe(:str?)
        required(:date).maybe(:date?)

        before(:key_coercer) do |result|
          { name: 'default' }.merge(result.to_h)
        end

        after(:rule_applier) do |result|
          result.to_h.compact
        end
      end
    end

    it 'calls callbacks' do
      expect(schema.(date: nil).to_h).to eql(name: 'default')
    end
  end
end
