require 'dry/schema/composer'
require 'dry/schema/compiler'

RSpec.describe Dry::Schema::Composer do
  subject(:composer) { Dry::Schema::Composer.new(compiler) }

  let(:compiler) { Dry::Schema::Compiler.new }

  describe '#to_rule' do
    it 'returns a rule for a single predicate without args' do
      rule = composer.str?

      expect(rule.("test")).to be_success
      expect(rule.(nil)).to be_failure
    end

    it 'returns a rule for a single predicate with args' do
      rule = composer.max_size?(4)

      expect(rule.("test")).to be_success
      expect(rule.("testing")).to be_failure
    end

    it 'returns AND operation for multiple predicates' do
      rule = composer.str?.and(composer.min_size?(4))

      expect(rule.("test")).to be_success
      expect(rule.(nil)).to be_failure
      expect(rule.("t")).to be_failure
    end

    it 'returns OR operation for multiple predicates' do
      rule = composer.str? | composer.int?

      expect(rule.("test")).to be_success
      expect(rule.(12)).to be_success
      expect(rule.(:test)).to be_failure
    end
  end
end
