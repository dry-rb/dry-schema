# frozen_string_literal: true

RSpec.describe 'Predicates: Type' do
  context 'with required' do
    subject(:schema) do
      Dry::Schema.Params do
        required(:foo).value(:integer)
      end
    end

    context 'with valid input' do
      let(:input) { { 'foo' => '23' } }

      it 'is successful' do
        expect(result).to be_successful
      end
    end

    context 'with missing input' do
      let(:input) { {} }

      it 'is not successful' do
        expect(result).to be_failing ['is missing', 'must be an integer']
      end
    end

    context 'with nil input' do
      let(:input) { { 'foo' => nil } }

      it 'is not successful' do
        expect(result).to be_failing ['must be an integer']
      end
    end

    context 'with blank input' do
      let(:input) { { 'foo' => '' } }

      it 'is not successful' do
        expect(result).to be_failing ['must be an integer']
      end
    end

    context 'with invalid type' do
      let(:input) { { 'foo' => ['x'] } }

      it 'is not successful' do
        expect(result).to be_failing ['must be an integer']
      end
    end
  end

  context 'with optional' do
    subject(:schema) do
      Dry::Schema.Params do
        optional(:foo).value(:integer)
      end
    end

    context 'with valid input' do
      let(:input) { { 'foo' => '23' } }

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
      let(:input) { { 'foo' => nil } }

      it 'is not successful' do
        expect(result).to be_failing ['must be an integer']
      end
    end

    context 'with blank input' do
      let(:input) { { 'foo' => '' } }

      it 'is not successful' do
        expect(result).to be_failing ['must be an integer']
      end
    end

    context 'with invalid type' do
      let(:input) { { 'foo' => ['x'] } }

      it 'is not successful' do
        expect(result).to be_failing ['must be an integer']
      end
    end
  end

  context 'as macro' do
    context 'with required' do
      context 'with value' do
        subject(:schema) do
          Dry::Schema.Params do
            required(:foo).value(:integer)
          end
        end

        context 'with valid input' do
          let(:input) { { 'foo' => '23' } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with missing input' do
          let(:input) { {} }

          it 'is not successful' do
            expect(result).to be_failing ['is missing', 'must be an integer']
          end
        end

        context 'with nil input' do
          let(:input) { { 'foo' => nil } }

          it 'is not successful' do
            expect(result).to be_failing ['must be an integer']
          end
        end

        context 'with blank input' do
          let(:input) { { 'foo' => '' } }

          it 'is not successful' do
            expect(result).to be_failing ['must be an integer']
          end
        end

        context 'with invalid type' do
          let(:input) { { 'foo' => ['x'] } }

          it 'is not successful' do
            expect(result).to be_failing ['must be an integer']
          end
        end
      end

      context 'with filled' do
        subject(:schema) do
          Dry::Schema.Params do
            required(:foo).filled(:integer)
          end
        end

        context 'with valid input' do
          let(:input) { { 'foo' => '23' } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with missing input' do
          let(:input) { {} }

          it 'is not successful' do
            expect(result).to be_failing ['is missing', 'must be an integer']
          end
        end

        context 'with nil input' do
          let(:input) { { 'foo' => nil } }

          it 'is not successful' do
            expect(result).to be_failing ['must be an integer']
          end
        end

        context 'with blank input' do
          let(:input) { { 'foo' => '' } }

          it 'is not successful' do
            expect(result).to be_failing ['must be an integer']
          end
        end

        context 'with invalid type' do
          let(:input) { { 'foo' => ['x'] } }

          it 'is not successful' do
            expect(result).to be_failing ['must be an integer']
          end
        end
      end

      context 'with maybe' do
        subject(:schema) do
          Dry::Schema.Params do
            required(:foo).maybe(:integer)
          end
        end

        context 'with valid input' do
          let(:input) { { 'foo' => '23' } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with missing input' do
          let(:input) { {} }

          it 'is not successful' do
            expect(result).to be_failing ['is missing', 'must be an integer']
          end
        end

        context 'with nil input' do
          let(:input) { { 'foo' => nil } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with blank input' do
          let(:input) { { 'foo' => '' } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with invalid type' do
          let(:input) { { 'foo' => ['x'] } }

          it 'is not successful' do
            expect(result).to be_failing ['must be an integer']
          end
        end
      end
    end

    context 'with optional' do
      context 'with value' do
        subject(:schema) do
          Dry::Schema.Params do
            optional(:foo).value(:integer)
          end
        end

        context 'with valid input' do
          let(:input) { { 'foo' => '23' } }

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
          let(:input) { { 'foo' => nil } }

          it 'is not successful' do
            expect(result).to be_failing ['must be an integer']
          end
        end

        context 'with blank input' do
          let(:input) { { 'foo' => '' } }

          it 'is not successful' do
            expect(result).to be_failing ['must be an integer']
          end
        end

        context 'with invalid type' do
          let(:input) { { 'foo' => ['x'] } }

          it 'is not successful' do
            expect(result).to be_failing ['must be an integer']
          end
        end
      end

      context 'with filled' do
        subject(:schema) do
          Dry::Schema.Params do
            optional(:foo).filled(:integer)
          end
        end

        context 'with valid input' do
          let(:input) { { 'foo' => '23' } }

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
          let(:input) { { 'foo' => nil } }

          it 'is not successful' do
            expect(result).to be_failing ['must be an integer']
          end
        end

        context 'with blank input' do
          let(:input) { { 'foo' => '' } }

          it 'is not successful' do
            expect(result).to be_failing ['must be an integer']
          end
        end

        context 'with invalid type' do
          let(:input) { { 'foo' => ['x'] } }

          it 'is not successful' do
            expect(result).to be_failing ['must be an integer']
          end
        end
      end

      context 'with maybe' do
        subject(:schema) do
          Dry::Schema.Params do
            optional(:foo).maybe(:integer)
          end
        end

        context 'with valid input' do
          let(:input) { { 'foo' => '23' } }

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
          let(:input) { { 'foo' => nil } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with blank input' do
          let(:input) { { 'foo' => '' } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with invalid type' do
          let(:input) { { 'foo' => ['x'] } }

          it 'is not successful' do
            expect(result).to be_failing ['must be an integer']
          end
        end
      end
    end
  end
end
