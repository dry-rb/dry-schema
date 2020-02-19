RSpec.describe Dry::Schema::JSON do
  it_behaves_like 'schema logic operators' do
    let(:schema_method) { :JSON }
  end

  context 'with coercion' do
    subject(:schema) do
      Dry::Schema.JSON do
        required(:user).hash(Test::UserSchema | Test::GuestSchema)
      end
    end

    before do
      Test::UserSchema = Dry::Schema.JSON do
        required(:login).filled(:string)
        required(:bday).value(:date_time)
      end

      Test::GuestSchema = Dry::Schema.JSON do
        required(:name).filled(:string)
      end
    end

    let(:result) do
      schema.(input)
    end

    context 'with unexpected keys' do
      let(:input) do
        { user: { foo: 'bar', login: 'jane', bday: DateTime.parse('1990-01-02') } }
      end

      it 'uses a merged key-map to sanitize keys' do
        expect(result[:user].keys).to eql(%i[login bday])
      end
    end

    context 'with values that need coercion' do
      let(:input) do
        { user: { login: 'jane', bday: '1990-01-02' } }
      end

      it 'uses a merged key-map to sanitize keys' do
        expect(result[:user]).to eql(login: 'jane', bday: DateTime.parse('1990-01-02'))
      end
    end
  end
end
