# frozen_string_literal: true

RSpec.describe 'Macros #filled' do
  describe 'with no args' do
    subject(:schema) do
      Dry::Schema.define do
        required(:email).filled
      end
    end

    it 'generates filled? rule' do
      expect(schema.(email: '').messages).to eql(
        email: ['must be filled']
      )
    end
  end

  describe 'with a type specification' do
    subject(:schema) do
      Dry::Schema.define do
        required(:age).filled(:string)
      end
    end

    it 'generates str? && filled? rule' do
      expect(schema.(age: nil).messages).to eql(
        age: ['must be a string']
      )
    end
  end

  describe 'with a predicate with args' do
    context 'with a flat arg' do
      subject(:schema) do
        Dry::Schema.define do
          required(:age).filled(:int?, gt?: 18)
        end
      end

      it 'generates filled? & int? & gt? rule' do
        expect(schema.(age: nil).messages).to eql(
          age: ['must be filled', 'must be greater than 18']
        )
      end
    end

    context 'with a range arg' do
      subject(:schema) do
        Dry::Schema.define do
          required(:age).filled(:int?, size?: 18..24)
        end
      end

      it 'generates filled? & int? & size? rule' do
        expect(schema.(age: nil).messages).to eql(
          age: ['must be filled', 'size must be within 18 - 24']
        )
      end
    end

    context 'with a block' do
      subject(:schema) do
        Dry::Schema.define do
          required(:age).filled { int? & size?(18..24) }
        end
      end

      it 'generates filled? & int? & size? rule' do
        expect(schema.(age: nil).messages).to eql(
          age: ['must be filled', 'size must be within 18 - 24']
        )
      end
    end

    context 'with a predicate and a block' do
      subject(:schema) do
        Dry::Schema.define do
          required(:age).filled(:int?) { size?(18..24) }
        end
      end

      it 'generates filled? & int? & size? rule' do
        expect(schema.(age: nil).messages).to eql(
          age: ['must be filled', 'size must be within 18 - 24']
        )
      end
    end
  end
end
