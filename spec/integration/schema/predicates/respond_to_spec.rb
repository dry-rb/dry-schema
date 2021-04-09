# frozen_string_literal: true

RSpec.fdescribe 'Predicates: Respond To' do
  xcontext 'with required' do
    subject(:schema) do
      Dry::Schema.define { required(:foo) { respond_to?(:bar) } }
    end

    context 'with valid input' do
      let(:input) { { foo: double(bar: 23) } }

      it 'is successful' do
        expect(result).to be_successful
      end
    end

    context 'with missing input' do
      let(:input) { {} }

      it 'is not successful' do
        expect(result).to be_failing ['is missing', 'must respond to bar']
      end
    end

    context 'with nil input' do
      let(:input) { { foo: nil } }

      it 'is not successful' do
        expect(result).to be_failing ['must respond to bar']
      end
    end

    context 'with blank input' do
      let(:input) { { foo: '' } }

      it 'is not successful' do
        expect(result).to be_failing ['must respond to bar']
      end
    end

    context 'with invalid input' do
      let(:input) { { foo: double(baz: 23) } }

      it 'is not successful' do
        expect(result).to be_failing ['must respond to bar']
      end
    end
  end

  xcontext 'with optional' do
    subject(:schema) do
      Dry::Schema.define { optional(:foo) { respond_to?(:bar) } }
    end

    context 'with valid input' do
      let(:input) { { foo: double(bar: 23) } }

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
        expect(result).to be_failing ['must respond to bar']
      end
    end

    context 'with blank input' do
      let(:input) { { foo: '' } }

      it 'is not successful' do
        expect(result).to be_failing ['must respond to bar']
      end
    end

    context 'with invalid input' do
      let(:input) { { foo: double(baz: 23) } }

      it 'is not successful' do
        expect(result).to be_failing ['must respond to bar']
      end
    end
  end

  context 'as macro' do
    context 'with required' do
      context 'with value' do
        subject(:schema) do
          Dry::Schema.define { required(:foo).value(respond_to?: :bar) }
        end

        context 'with valid input' do
          let(:input) { { foo: double(bar: 23) } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with missing input' do
          let(:input) { {} }

          it 'is not successful' do
            expect(result).to be_failing ['is missing', 'must respond to bar']
          end
        end

        context 'with nil input' do
          let(:input) { { foo: nil } }

          it 'is not successful' do
            expect(result).to be_failing ['must respond to bar']
          end
        end

        context 'with blank input' do
          let(:input) { { foo: '' } }

          it 'is not successful' do
            expect(result).to be_failing ['must respond to bar']
          end
        end

        context 'with invalid input' do
          let(:input) { { foo: double(baz: 23) } }

          it 'is not successful' do
            expect(result).to be_failing ['must respond to bar']
          end
        end
      end

      fcontext 'with filled' do
        subject(:schema) do
          Dry::Schema.define { required(:foo).filled(respond_to?: :bar) }
        end

        context 'with valid input' do
          let(:input) { { foo: double(bar: 23) } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with missing input' do
          let(:input) { {} }

          it 'is not successful' do
            expect(result).to be_failing ['is missing', 'must respond to bar']
          end
        end

        context 'with nil input' do
          let(:input) { { foo: nil } }

          it 'is not successful' do
            expect(result).to be_failing ['must be filled', 'must respond to bar']
          end
        end

        context 'with blank input' do
          let(:input) { { foo: '' } }

          it 'is not successful' do
            expect(result).to be_failing ['must be filled', 'must respond to bar']
          end
        end

        context 'with invalid input' do
          let(:input) { { foo: double(baz: 23) } }

          it 'is not successful' do
            expect(result).to be_failing ['must respond to bar']
          end
        end
      end

      context 'with maybe' do
        subject(:schema) do
          Dry::Schema.define { required(:foo).maybe(respond_to?: :bar) }
        end

        context 'with valid input' do
          let(:input) { { foo: double(bar: 23) } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with missing input' do
          let(:input) { {} }

          it 'is not successful' do
            expect(result).to be_failing ['is missing', 'must respond to bar']
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
            expect(result).to be_failing ['must respond to bar']
          end
        end

        context 'with invalid input' do
          let(:input) { { foo: double(baz: 23) } }

          it 'is not successful' do
            expect(result).to be_failing ['must respond to bar']
          end
        end
      end
    end

    context 'with optional' do
      context 'with value' do
        subject(:schema) do
          Dry::Schema.define { optional(:foo).value(respond_to?: :bar) }
        end

        context 'with valid input' do
          let(:input) { { foo: double(bar: 23) } }

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
            expect(result).to be_failing ['must respond to bar']
          end
        end

        context 'with blank input' do
          let(:input) { { foo: '' } }

          it 'is not successful' do
            expect(result).to be_failing ['must respond to bar']
          end
        end

        context 'with invalid input' do
          let(:input) { { foo: double(baz: 23) } }

          it 'is not successful' do
            expect(result).to be_failing ['must respond to bar']
          end
        end
      end

      context 'with filled' do
        subject(:schema) do
          Dry::Schema.define { optional(:foo).filled(respond_to?: :bar) }
        end

        context 'with valid input' do
          let(:input) { { foo: double(bar: 23) } }

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
            expect(result).to be_failing ['must be filled', 'must respond to bar']
          end
        end

        context 'with blank input' do
          let(:input) { { foo: '' } }

          it 'is not successful' do
            expect(result).to be_failing ['must be filled', 'must respond to bar']
          end
        end

        context 'with invalid input' do
          let(:input) { { foo: double(baz: 23) } }

          it 'is not successful' do
            expect(result).to be_failing ['must respond to bar']
          end
        end
      end

      context 'with maybe' do
        subject(:schema) do
          Dry::Schema.define { optional(:foo).maybe(respond_to?: :bar) }
        end

        context 'with valid input' do
          let(:input) { { foo: double(bar: 23) } }

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
            expect(result).to be_failing ['must respond to bar']
          end
        end

        context 'with invalid input' do
          let(:input) { { foo: double(baz: 23) } }

          it 'is not successful' do
            expect(result).to be_failing ['must respond to bar']
          end
        end
      end
    end
  end
end
