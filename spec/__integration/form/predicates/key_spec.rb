RSpec.describe 'Predicates: Key' do
  context 'with required' do
    it "raises error" do
      expect { Dry::Schema.form { required(:foo) { key? } } }.to raise_error Dry::Schema::InvalidSchemaError
    end
  end

  context 'with optional' do
    it "raises error" do
      expect { Dry::Schema.form { optional(:foo) { key? } } }.to raise_error Dry::Schema::InvalidSchemaError
    end
  end

  context 'as macro' do
    context 'with required' do
      context 'with value' do
        it "raises error" do
          expect { Dry::Schema.form do
            required(:foo).value(:key?)
          end }.to raise_error Dry::Schema::InvalidSchemaError
        end
      end

      context 'with filled' do
        it "raises error" do
          expect { Dry::Schema.form do
            required(:foo).filled(:key?)
          end }.to raise_error Dry::Schema::InvalidSchemaError
        end
      end

      context 'with maybe' do
        it "raises error" do
          expect { Dry::Schema.form do
            required(:foo).maybe(:key?)
          end }.to raise_error Dry::Schema::InvalidSchemaError
        end
      end
    end

    context 'with optional' do
      context 'with value' do
        it "raises error" do
          expect { Dry::Schema.build do
            optional(:foo).value(:key?)
          end }.to raise_error Dry::Schema::InvalidSchemaError
        end
      end

      context 'with filled' do
        it "raises error" do
          expect { Dry::Schema.build do
            optional(:foo).filled(:key?)
          end }.to raise_error Dry::Schema::InvalidSchemaError
        end
      end

      context 'with maybe' do
        it "raises error" do
          expect { Dry::Schema.build do
            optional(:foo).maybe(:key?)
          end }.to raise_error Dry::Schema::InvalidSchemaError
        end
      end
    end
  end
end
