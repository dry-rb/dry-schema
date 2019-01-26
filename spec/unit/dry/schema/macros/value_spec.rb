require 'dry/schema/macros/value'

RSpec.describe Dry::Schema::Macros::Value do
  subject(:macro) do
    Dry::Schema::Macros::Value.new(:name)
  end

  describe '#call' do
    it 'builds a valid rule with additional predicates' do
      macro.(:str?, size?: 2..20)

      rule = macro.to_rule

      expect(rule.("foobar")).to be_success
      expect(rule.("f")).to be_failure
      expect(rule.("foo"*20)).to be_failure
    end
  end

  describe '#method_missing' do
    it 'returns a predicate when method ends with a question mark' do
      rule = macro.str?.to_rule

      expect(rule.("foobar")).to be_success
      expect(rule.(:foobar)).to be_failure
    end

    it 'raises NoMethodError otherwise' do
      expect { macro.not_here }.to raise_error(NoMethodError, /not_here/)
    end
  end
end
