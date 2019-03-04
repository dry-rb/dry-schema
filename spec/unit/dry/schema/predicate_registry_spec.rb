# frozen_string_literal: true

require 'dry/schema/predicate_registry'

RSpec.describe Dry::Schema::PredicateRegistry do
  subject(:predicate_registry) { Dry::Schema::PredicateRegistry.new }

  describe '#[]' do
    it 'gives access to built-in predicates' do
      expect(predicate_registry[:filled?].('sutin')).to be(true)
    end
  end
end
