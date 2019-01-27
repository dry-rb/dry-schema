require 'dry/schema/params'

RSpec.describe Dry::Schema::Params do
  describe '.new' do
    subject(:klass) do
      class Test::UserSchema < Dry::Schema::Params
        define do
          required(:name).filled(:string)
          required(:age).filled(:integer)
        end
      end
    end

    it 'returns a params schema instance' do
      schema = klass.new

      expect(schema.('name' => 'Jane', 'age' => '').errors).to eql(age: ['must be filled'])
    end
  end

  describe 'inheritance' do
    let(:parent_class) do
      class Test::UserSchema < Dry::Schema::Params
        define do
          required(:name).filled(:string)
        end
      end
    end

    let(:child_class) do
      class Test::OtherUserSchema < parent_class
        define do
          required(:age).filled(:integer)
        end
      end
    end

    it 'inherits settings and rules from parent' do
      schema = child_class.new

      expect(schema.('name' => '', 'age' => '18').errors).to eql(name: ['must be filled'])
      expect(schema.('name' => 'Jane', 'age' => 'foo').errors).to eql(age: ['must be an integer'])
    end
  end
end