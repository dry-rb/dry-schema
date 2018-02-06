require 'dry/schema/macros/each'

RSpec.describe Dry::Schema::Macros::Each do
  subject(:macro) do
    Dry::Schema::Macros::Each.new(:name)
  end

  describe '#to_rule' do
    it 'builds a valid rule with additional predicates' do
      rule = macro.str?.size?(2..20)

      expect(rule.(["foo", "foobar"])).to be_success
      expect(rule.(["f", "foo"])).to be_failure
      expect(rule.(["f", "foo"*20])).to be_failure
    end
  end
end
