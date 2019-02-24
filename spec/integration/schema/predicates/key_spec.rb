RSpec.describe 'Predicates: Key' do
  context 'inferred from required/optional macros' do
    subject(:schema) do
      Dry::Schema.define do
        required(:foo).value(:str?)
        optional(:bar).value(:int?)
      end
    end

    it 'uses key? predicate for required' do
      expect(schema.({}).messages(full: true)).to eql(foo: ['foo is missing', 'foo must be a string'])
      expect(schema.({}).messages).to eql(foo: ['is missing', 'must be a string'])
    end
  end

  context 'with required' do
    it "should raise error" do
      expect { Dry::Schema.define do
        required(:foo) { key? }
      end }.to raise_error Dry::Schema::InvalidSchemaError
    end
  end

  context 'with optional' do
    subject(:schema) do
      it "should raise error" do
        expect { Dry::Schema.define do
          optional(:foo) { key? }
        end }.to raise_error Dry::Schema::InvalidSchemaError
      end
    end
  end

  context 'as macro' do
    context 'with required' do
      context 'with value' do
        it "should raise error" do
          expect { Dry::Schema.define do
            required(:foo).value(:key?)
          end }.to raise_error Dry::Schema::InvalidSchemaError
        end
      end

      context 'with filled' do
        it "should raise error" do
          expect { Dry::Schema.define do
            required(:foo).filled(:key?)
          end }.to raise_error Dry::Schema::InvalidSchemaError
        end
      end

      context 'with maybe' do
        it "should raise error" do
          expect { Dry::Schema.define do
            required(:foo).maybe(:key?)
          end }.to raise_error Dry::Schema::InvalidSchemaError
        end
      end
    end

    context 'with optional' do
      context 'with value' do
        it "should raise error" do
          expect { Dry::Schema.define do
            optional(:foo).value(:key?)
          end }.to raise_error Dry::Schema::InvalidSchemaError
        end
      end

      context 'with filled' do
        it "should raise error" do
          expect { Dry::Schema.define do
            optional(:foo).filled(:key?)
          end }.to raise_error Dry::Schema::InvalidSchemaError
        end
      end

      context 'with maybe' do
        it "should raise error" do
          expect { Dry::Schema.define do
            optional(:foo).maybe(:key?)
          end }.to raise_error Dry::Schema::InvalidSchemaError
        end
      end
    end
  end
end
