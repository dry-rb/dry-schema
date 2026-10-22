# frozen_string_literal: true

RSpec.describe Dry::Schema::Macros::DSL do
  describe "MACRO_OPTIONS" do
    # Predicate keywords may omit their question mark, so a macro option sharing a name with a
    # built-in predicate would silently take over that predicate's keyword.
    it "does not clash with any built-in predicate name" do
      predicate_names = Dry::Logic::Predicates::Methods.instance_methods
        .map { _1.to_s.delete_suffix("?").to_sym }

      expect(described_class::MACRO_OPTIONS & predicate_names).to be_empty
    end
  end
end
