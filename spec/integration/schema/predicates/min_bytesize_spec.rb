# frozen_string_literal: true

RSpec.describe 'Predicates: Min Bytesize' do
  context 'with required' do
    subject(:schema) do
      Dry::Schema.define do
        required(:foo) { min_bytesize?(3) }
      end
    end

    context 'with valid input' do
      let(:input) { { foo: 'abc' } }

      it 'is successful' do
        expect(result).to be_successful
      end
    end

    context 'with missing input' do
      let(:input) { {} }

      it 'is not successful' do
        expect(result).to be_failing ['is missing', 'bytesize cannot be less than 3']
      end
    end

    context 'with nil input' do
      let(:input) { { foo: nil } }

      it 'is raises error' do
        expect { result }.to raise_error(NoMethodError)
      end
    end

    context 'with blank input' do
      let(:input) { { foo: '' } }

      it 'is not successful' do
        expect(result).to be_failing ['bytesize cannot be less than 3']
      end
    end

    context 'with invalid input' do
      let(:input) { { foo: 'ab' } }

      it 'is not successful' do
        expect(result).to be_failing ['bytesize cannot be less than 3']
      end
    end
  end

  context 'with optional' do
    subject(:schema) do
      Dry::Schema.define do
        optional(:foo) { min_bytesize?(3) }
      end
    end

    context 'with valid input' do
      let(:input) { { foo: 'abc' } }

      it 'is successful' do
        expect(result).to be_successful
      end
    end

    context 'with missing input' do
      let(:input) { {} }

      it 'is successful' do
        expect(result).to be_successful
      end
    end

    context 'with nil input' do
      let(:input) { { foo: nil } }

      it 'is raises error' do
        expect { result }.to raise_error(NoMethodError)
      end
    end

    context 'with blank input' do
      let(:input) { { foo: '' } }

      it 'is not successful' do
        expect(result).to be_failing ['bytesize cannot be less than 3']
      end
    end

    context 'with invalid input' do
      let(:input) { { foo: 'ab' } }

      it 'is not successful' do
        expect(result).to be_failing ['bytesize cannot be less than 3']
      end
    end
  end

  context 'as macro' do
    context 'with required' do
      context 'with value' do
        subject(:schema) do
          Dry::Schema.define do
            required(:foo).value(min_bytesize?: 3)
          end
        end

        context 'with valid input' do
          let(:input) { { foo: 'abc' } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with missing input' do
          let(:input) { {} }

          it 'is not successful' do
            expect(result).to be_failing ['is missing', 'bytesize cannot be less than 3']
          end
        end

        context 'with nil input' do
          let(:input) { { foo: nil } }

          it 'is raises error' do
            expect { result }.to raise_error(NoMethodError)
          end
        end

        context 'with blank input' do
          let(:input) { { foo: '' } }

          it 'is not successful' do
            expect(result).to be_failing ['bytesize cannot be less than 3']
          end
        end

        context 'with invalid input' do
          let(:input) { { foo: 'ab' } }

          it 'is not successful' do
            expect(result).to be_failing ['bytesize cannot be less than 3']
          end
        end
      end

      context 'with filled' do
        subject(:schema) do
          Dry::Schema.define do
            required(:foo).filled(min_bytesize?: 3)
          end
        end

        context 'with valid input' do
          let(:input) { { foo: 'abc' } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with missing input' do
          let(:input) { {} }

          it 'is not successful' do
            expect(result).to be_failing ['is missing', 'bytesize cannot be less than 3']
          end
        end

        context 'with nil input' do
          let(:input) { { foo: nil } }

          it 'is not successful' do
            expect(result).to be_failing ['must be filled', 'bytesize cannot be less than 3']
          end
        end

        context 'with blank input' do
          let(:input) { { foo: '' } }

          it 'is not successful' do
            expect(result).to be_failing ['must be filled', 'bytesize cannot be less than 3']
          end
        end

        context 'with invalid input' do
          let(:input) { { foo: 'ab' } }

          it 'is not successful' do
            expect(result).to be_failing ['bytesize cannot be less than 3']
          end
        end
      end

      context 'with maybe' do
        subject(:schema) do
          Dry::Schema.define do
            required(:foo).maybe(min_bytesize?: 3)
          end
        end

        context 'with valid input' do
          let(:input) { { foo: 'abc' } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with missing input' do
          let(:input) { {} }

          it 'is not successful' do
            expect(result).to be_failing ['is missing', 'bytesize cannot be less than 3']
          end
        end

        context 'with nil input' do
          let(:input) { { foo: nil } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with blank input' do
          let(:input) { { foo: '' } }

          it 'is not successful' do
            expect(result).to be_failing ['bytesize cannot be less than 3']
          end
        end

        context 'with invalid input' do
          let(:input) { { foo: 'ab' } }

          it 'is not successful' do
            expect(result).to be_failing ['bytesize cannot be less than 3']
          end
        end
      end
    end

    context 'with optional' do
      context 'with value' do
        subject(:schema) do
          Dry::Schema.define do
            optional(:foo).value(min_bytesize?: 3)
          end
        end

        context 'with valid input' do
          let(:input) { { foo: 'abc' } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with missing input' do
          let(:input) { {} }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with nil input' do
          let(:input) { { foo: nil } }

          it 'is raises error' do
            expect { result }.to raise_error(NoMethodError)
          end
        end

        context 'with blank input' do
          let(:input) { { foo: '' } }

          it 'is not successful' do
            expect(result).to be_failing ['bytesize cannot be less than 3']
          end
        end

        context 'with invalid input' do
          let(:input) { { foo: 'ab' } }

          it 'is not successful' do
            expect(result).to be_failing ['bytesize cannot be less than 3']
          end
        end
      end

      context 'with filled' do
        subject(:schema) do
          Dry::Schema.define do
            optional(:foo).filled(min_bytesize?: 3)
          end
        end

        context 'with valid input' do
          let(:input) { { foo: 'abc' } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with missing input' do
          let(:input) { {} }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with nil input' do
          let(:input) { { foo: nil } }

          it 'is not successful' do
            expect(result).to be_failing ['must be filled', 'bytesize cannot be less than 3']
          end
        end

        context 'with blank input' do
          let(:input) { { foo: '' } }

          it 'is not successful' do
            expect(result).to be_failing ['must be filled', 'bytesize cannot be less than 3']
          end
        end

        context 'with invalid input' do
          let(:input) { { foo: 'ab' } }

          it 'is not successful' do
            expect(result).to be_failing ['bytesize cannot be less than 3']
          end
        end
      end

      context 'with maybe' do
        subject(:schema) do
          Dry::Schema.define do
            optional(:foo).maybe(min_bytesize?: 3)
          end
        end

        context 'with valid input' do
          let(:input) { { foo: 'abc' } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with missing input' do
          let(:input) { {} }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with nil input' do
          let(:input) { { foo: nil } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with blank input' do
          let(:input) { { foo: '' } }

          it 'is not successful' do
            expect(result).to be_failing ['bytesize cannot be less than 3']
          end
        end

        context 'with invalid input' do
          let(:input) { { foo: 'ab' } }

          it 'is not successful' do
            expect(result).to be_failing ['bytesize cannot be less than 3']
          end
        end
      end
    end
  end
end
