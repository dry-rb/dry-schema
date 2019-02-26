RSpec.describe Dry::Schema do
  describe 'defining schema with optional keys' do
    subject(:schema) do
      Dry::Schema.define do
        optional(:email).value(:filled?)

        required(:address).hash do
          required(:city).value(:filled?)
          required(:street).value(:filled?)

          optional(:phone_number) do
            nil? | str?
          end
        end
      end
    end

    describe '#call' do
      it 'skips rules when key is not present' do
        expect(schema.(address: { city: 'NYC', street: 'Street 1/2' })).to be_success
      end

      it 'applies rules when key is present' do
        expect(schema.(email: '')).to_not be_success
      end
    end
  end
end
