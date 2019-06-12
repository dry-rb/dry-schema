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
    context ':string' do
      subject(:schema) do
        Dry::Schema.define do
          required(:name).filled(:string)
        end
      end

      it 'generates str? && filled? rule' do
        expect(schema.(name: nil).errors).to eql(name: ['must be a string'])
      end
    end

    context ':integer' do
      context 'Params' do
        subject(:schema) do
          Dry::Schema.Params do
            required(:age).filled(:integer)

            required(:address).hash do
              required(:zipcode).filled(:integer)
            end
          end
        end

        it 'applies filter(:filled?) for empty strings' do
          expect(schema.(age: '', address: { zipcode: '123' }).errors).to eql(age: ['must be filled'])
        end

        it 'applies filter(:filled?) for empty strings under nested keys' do
          expect(schema.(age: '41', address: { zipcode: '' }).errors)
            .to eql(address: { zipcode: ['must be filled'] })
        end

        it 'applies filter(:filled?) for nil' do
          expect(schema.(age: nil, address: { zipcode: '123' }).errors)
            .to eql(age: ['must be filled'])
        end

        it 'applies int?' do
          expect(schema.(age: 'not-a-number', address: { zipcode: '123' }).errors)
            .to eql(age: ['must be an integer'])
        end
      end

      context 'JSON' do
        subject(:schema) do
          Dry::Schema.JSON do
            required(:age).filled(:integer)
          end
        end

        it 'applies type-spec predicate for empty strings' do
          expect(schema.(age: '').errors).to eql(age: ['must be an integer'])
        end

        it 'applies type-spec predicate for nil' do
          expect(schema.(age: nil).errors).to eql(age: ['must be an integer'])
        end

        it 'applies int?' do
          expect(schema.(age: 'not-a-number').errors).to eql(age: ['must be an integer'])
        end
      end
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
