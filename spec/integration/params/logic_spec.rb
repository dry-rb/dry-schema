RSpec.describe Dry::Schema::Params do
  it_behaves_like 'schema logic operators' do
    let(:schema_method) { :Params }
  end

  before do
    Test::UserSchema = Dry::Schema.Params do
      required(:login).filled(:string)
      required(:age).value(:integer)
    end

    Test::GuestSchema = Dry::Schema.Params do
      required(:name).filled(:string)
    end
  end

  context 'with a hash that needs coercion' do
    shared_examples 'nested composed schemas' do
      context 'with coercion' do
        let(:result) do
          schema.(input)
        end

        context 'with unexpected keys' do
          let(:input) do
            { user: { foo: 'bar', login: 'jane', age: 36 } }
          end

          it 'uses a merged key-map to sanitize keys' do
            expect(result[:user].keys).to eql(%i[login age])
          end
        end

        context 'with values that need coercion' do
          let(:input) do
            { user: { login: 'jane', age: '36' } }
          end

          it 'uses a merged key-map to sanitize keys' do
            expect(result[:user]).to eql(login: 'jane', age: 36)
          end
        end

        context 'with invalid values' do
          let(:input) do
            { user: { login: '', age: '36' } }
          end

          it 'builds a nested error hash' do
            expect(result.errors[:user]).to eql(
              or: [{ login: ['must be filled'] }, { name: ['is missing'] }]
            )
          end
        end
      end
    end

    context 'using `hash`' do
      subject(:schema) do
        Dry::Schema.Params do
          required(:user).hash(Test::UserSchema | Test::GuestSchema)
        end
      end

      include_context 'nested composed schemas'
    end

    context 'using `schema`' do
      subject(:schema) do
        Dry::Schema.Params do
          required(:user).schema(Test::UserSchema | Test::GuestSchema)
        end
      end

      include_context 'nested composed schemas'
    end
  end

  context 'with an array with hashes that need coercion' do
    context 'with coercion' do
      subject(:schema) do
        Dry::Schema.Params do
          required(:sites).array(:hash, Test::UserSchema | Test::GuestSchema)
        end
      end

      let(:result) do
        schema.(input)
      end

      context 'with unexpected keys' do
        let(:input) do
          { sites: [
            { foo: 'bar', login: 'jane', age: 36 },
            { bar: 'foo', login: 'john', age: 25 }
          ] }
        end

        it 'uses a merged key-map to sanitize keys' do
          expect(result[:sites][0].keys).to eql(%i[login age])
          expect(result[:sites][1].keys).to eql(%i[login age])
        end
      end

      context 'with values that need coercion' do
        let(:input) do
          { sites: [
            { login: 'jane', age: '36' },
            { login: 'john', age: '25' }
          ] }
        end

        it 'uses a merged key-map to sanitize keys' do
          expect(result[:sites][0]).to eql(login: 'jane', age: 36)
          expect(result[:sites][1]).to eql(login: 'john', age: 25)
        end
      end

      context 'with invalid values' do
        let(:input) do
          { sites: [
            { login: 'jane', age: '' },
            { name: '' },
            { login: '', age: '25' }
          ] }
        end

        it 'builds a deeply nested error hash' do
          expect(result.errors[:sites]).to eql(
            0 => {
              or: [
                { age: ['must be an integer'] },
                { name: ['is missing'] }
              ]
            },
            1 => {
              or: [
                { age: ['is missing'], login: ['is missing'] },
                { name: ['must be filled'] }
              ]
            },
            2 => {
              or: [
                { login: ['must be filled'] },
                { name: ['is missing'] }
              ]
            }
          )
        end
      end
    end
  end

  context 'with an array with deeply nested hashes that need coercion' do
    context 'with coercion' do
      subject(:schema) do
        Dry::Schema.Params do
          required(:sites).array(:hash) do
            required(:visitor).hash(Test::UserSchema | Test::GuestSchema)
          end
        end
      end

      let(:result) do
        schema.(input)
      end

      context 'with unexpected keys' do
        let(:input) do
          { sites: [
              { visitor: { foo: 'bar', login: 'jane', age: 36 } },
              { visitor: { bar: 'foo', login: 'john', age: 25 } }
            ] }
        end

        it 'uses a merged key-map to sanitize keys' do
          expect(result[:sites][0][:visitor].keys).to eql(%i[login age])
          expect(result[:sites][1][:visitor].keys).to eql(%i[login age])
        end
      end

      context 'with values that need coercion' do
        let(:input) do
          { sites: [
              { visitor: { login: 'jane', age: '36' } },
              { visitor: { login: 'john', age: '25' } }
            ] }
        end

        it 'uses a merged key-map to sanitize keys' do
          expect(result[:sites][0][:visitor]).to eql(login: 'jane', age: 36)
          expect(result[:sites][1][:visitor]).to eql(login: 'john', age: 25)
        end
      end
    end
  end
end
