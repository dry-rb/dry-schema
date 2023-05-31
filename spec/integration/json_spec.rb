# frozen_string_literal: true

require "dry/schema"

RSpec.describe Dry::Schema::JSON do
  it_behaves_like "schema with custom predicates" do
    let(:schema_class) { Class.new(Dry::Schema::JSON) }
  end
end
