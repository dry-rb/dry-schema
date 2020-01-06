# frozen_string_literal: true

RSpec.describe 'Predicates: Key' do
  context 'with required' do
    it 'raises error' do
      expect { Dry::Schema.Params { required(:foo) { key? } } }.to raise_error Dry::Schema::InvalidSchemaError
    end
  end

  context 'with optional' do
    it 'raises error' do
      expect { Dry::Schema.Params { optional(:foo) { key? } } }.to raise_error Dry::Schema::InvalidSchemaError
    end
  end

  context 'as macro' do
    context 'with required' do
      context 'with value' do
        it 'raises error' do
          expect {
            Dry::Schema.Params do
              required(:foo).value(:key?)
            end
          } .to raise_error Dry::Schema::InvalidSchemaError
        end
      end

      context 'with filled' do
        it 'raises error' do
          expect {
            Dry::Schema.Params do
              required(:foo).filled(:key?)
            end
          } .to raise_error Dry::Schema::InvalidSchemaError
        end
      end

      context 'with maybe' do
        it 'raises error' do
          expect {
            Dry::Schema.Params do
              required(:foo).maybe(:key?)
            end
          } .to raise_error Dry::Schema::InvalidSchemaError
        end
      end
    end

    context 'with optional' do
      context 'with value' do
        it 'raises error' do
          expect {
            Dry::Schema.Params do
              optional(:foo).value(:key?)
            end
          } .to raise_error Dry::Schema::InvalidSchemaError
        end
      end

      context 'with filled' do
        it 'raises error' do
          expect {
            Dry::Schema.Params do
              optional(:foo).filled(:key?)
            end
          } .to raise_error Dry::Schema::InvalidSchemaError
        end
      end

      context 'with maybe' do
        it 'raises error' do
          expect {
            Dry::Schema.Params do
              optional(:foo).maybe(:key?)
            end
          } .to raise_error Dry::Schema::InvalidSchemaError
        end
      end
    end
  end
end
