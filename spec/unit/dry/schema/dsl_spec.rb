require 'dry/schema/dsl'
require 'dry/schema/compiler'

RSpec.describe Dry::Schema::DSL do
  subject(:dsl) do
    Dry::Schema::DSL.new(Dry::Schema::Compiler.new)
  end

  describe '#schema' do
    it 'defines a rule from a nested schema' do
      dsl.required(:user).schema do
        required(:name).filled
      end

      rules = dsl.call.rules

      expect(rules[:user].(user: { name: 'Jane' })).to be_success

      expect(rules[:user].(user: {})).to be_failure
      expect(rules[:user].(user: { name: '' })).to be_failure
    end
  end
end
