# frozen_string_literal: true

RSpec.describe 'Schema with each' do
  subject(:schema) do
    Dry::Schema.define do
      each do
        schema do
          required(:method).filled(:str?)
          required(:amount).filled(:float?)
        end
      end
    end
  end

  describe '#messages' do
    it 'validates root array' do
      expect(schema.([{}]).messages).to eql(
        0 => { method: ['is missing', 'must be a string'], amount: ['is missing', 'must be a float'] }
      )
    end

    it 'validates each element against its set of rules' do
      input = [
        { method: 'cc', amount: 1.23 },
        { method: 'wire', amount: 4.56 }
      ]

      expect(schema.(input).messages).to eql({})
    end

    it 'validates presence of the method key for each element' do
      input = [
        { method: 'cc', amount: 1.23 },
        { amount: 4.56 }
      ]

      expect(schema.(input).messages).to eql(
        1 => { method: ['is missing', 'must be a string'] }
      )
    end

    it 'validates type of the method value for each element' do
      input = [
        { method: 'cc', amount: 1.23 },
        { method: 12, amount: 4.56 }
      ]

      expect(schema.(input).messages).to eql(
        1 => { method: ['must be a string'] }
      )
    end

    it 'validates type of the amount value for each element' do
      input = [
        { method: 'cc', amount: 1.23 },
        { method: 'wire', amount: '4.56' }
      ]

      expect(schema.(input).messages).to eql(
        1 => { amount: ['must be a float'] }
      )
    end
  end

  context 'with array of strings' do
    subject(:schema) do
      Dry::Schema.define do
        each(:integer, gt?: 0)
      end
    end

    describe '#messages' do
      it 'validates root array' do
        expect(schema.([{}]).messages).to eql(0 => ['must be an integer', 'must be greater than 0'])
      end

      it 'validates each element' do
        input = [1, 2, 3]

        expect(schema.(input).messages).to eql({})
      end

      it 'validates each element against its rules' do
        input = [1, -1, 3]

        expect(schema.(input).messages).to eql(1 => ['must be greater than 0'])
      end
    end
  end
end
