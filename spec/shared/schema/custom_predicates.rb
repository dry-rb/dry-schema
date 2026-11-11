# frozen_string_literal: true

RSpec.shared_examples_for "schema with custom predicates" do
  describe "config.predicates" do
    subject(:schema) { schema_class.new }

    before do
      module Test
        module Predicates
          include Dry::Logic::Predicates

          def self.future_date?(date)
            date > Date.today
          end
        end
      end

      schema_class.define do
        config.predicates = Test::Predicates
        config.messages.load_paths << SPEC_ROOT.join("fixtures/locales/en.yml")

        required(:release_date).value(:date, :future_date?)
      end
    end

    it "allows setting a module with custom predicate functions" do
      expect(schema.(release_date: Date.today)).to be_failure
      expect(schema.(release_date: Date.today).errors.to_h).to eql(release_date: ["must be in the future"])
      expect(schema.(release_date: Date.today + 1)).to be_success
    end
  end
end
