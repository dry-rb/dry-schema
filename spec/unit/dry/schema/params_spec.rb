# frozen_string_literal: true

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

    it 'raises exception when definition is missing' do
      expect { Class.new(Dry::Schema::Params).new }.
        to raise_error(ArgumentError, 'Cannot create a schema without a definition')
    end
  end

  describe '#inspect' do
    subject(:klass) do
      class Test::UserSchema < Dry::Schema::Params
        define do
          required(:name).filled(:string)
        end
      end
    end

    it 'returns a representation of a params object' do
      expect(klass.new.inspect).to eql(<<~STR.strip)
        #<Test::UserSchema keys=["name"] rules={:name=>"key?(:name) AND key[name](str?)"}>
      STR
    end

    it 'raises exception when definition is missing' do
      expect { Class.new(Dry::Schema::Params).new }.
        to raise_error(ArgumentError, 'Cannot create a schema without a definition')
    end
  end

  describe 'inheritance' do
    let(:parent_class) do
      class Test::UserSchema < Dry::Schema::Params
        define do
          config.messages.backend = :i18n

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
      expect(schema.config.messages.backend).to eql(:i18n)
    end
  end

  describe '#to_proc' do
    it 'returns a proc' do
      schema = Dry::Schema.Params { required(:name).filled(:string) }

      expect(schema.to_proc.(name: '').errors).to eql(name: ['must be filled'])
    end
  end
end
