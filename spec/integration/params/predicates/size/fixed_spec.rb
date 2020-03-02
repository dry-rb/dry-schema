# frozen_string_literal: true

RSpec.describe 'Predicates: Size' do
  context 'Fixed (integer)' do
    context 'with required' do
      subject(:schema) do
        Dry::Schema.Params do
          required(:foo).value(:string) { size?(3) }
        end
      end

      context 'with valid input' do
        let(:input) { { 'foo' => 'bar' } }

        it 'is successful' do
          expect(result).to be_successful
        end
      end

      context 'with missing input' do
        let(:input) { {} }

        it 'is not successful' do
          expect(result).to be_failing ['is missing', 'must be a string', 'size must be 3']
        end
      end

      context 'with nil input' do
        let(:input) { { 'foo' => nil } }

        it 'is not successful' do
          expect(result).to be_failing ['must be a string', 'size must be 3']
        end
      end

      context 'with blank input' do
        let(:input) { { 'foo' => '' } }

        it 'is not successful' do
          expect(result).to be_failing ['length must be 3']
        end
      end

      context 'with invalid input' do
        let(:input) { { 'foo' => { 'a' => '1', 'b' => '2', 'c' => '3', 'd' => '4' } } }

        it 'is not successful' do
          expect(result).to be_failing ['must be a string', 'size must be 3']
        end
      end
    end

    context 'with optional' do
      subject(:schema) do
        Dry::Schema.Params do
          optional(:foo).value([:integer, :string]) { size?(3) }
        end
      end

      context 'with valid input' do
        let(:input) { { 'foo' => 'bar' } }

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
          expect(result).to be_failing ['must be an integer or must be a string', 'size must be 3']
        end
      end

      context 'with blank input' do
        let(:input) { { 'foo' => '' } }

        it 'is not successful' do
          expect(result).to be_failing ['length must be 3']
        end
      end

      context 'with invalid input' do
        let(:input) { { 'foo' => { 'a' => '1', 'b' => '2', 'c' => '3', 'd' => '4' } } }

        it 'is not successful' do
          expect(result).to be_failing ['must be an integer or must be a string', 'size must be 3']
        end
      end
    end

    context 'as macro' do
      context 'with required' do
        context 'with value' do
          subject(:schema) do
            Dry::Schema.Params do
              required(:foo).value([:integer, :string], size?: 3)
            end
          end

          context 'with valid input' do
            let(:input) { { 'foo' => 'bar' } }

            it 'is successful' do
              expect(result).to be_successful
            end
          end

          context 'with missing input' do
            let(:input) { {} }

            it 'is not successful' do
              expect(result).to be_failing ['is missing', 'must be an integer or must be a string', 'size must be 3']
            end
          end

          context 'with nil input' do
            let(:input) { { 'foo' => nil } }

            it 'is not successful' do
              expect(result).to be_failing ['must be an integer or must be a string', 'size must be 3']
            end
          end

          context 'with blank input' do
            let(:input) { { 'foo' => '' } }

            it 'is not successful' do
              expect(result).to be_failing ['length must be 3']
            end
          end

          context 'with invalid input' do
            let(:input) { { 'foo' => { 'a' => '1', 'b' => '2', 'c' => '3', 'd' => '4' } } }

            it 'is not successful' do
              expect(result).to be_failing ['must be an integer or must be a string', 'size must be 3']
            end
          end
        end

        context 'with filled' do
          subject(:schema) do
            Dry::Schema.Params do
              required(:foo).filled([:array, :string], size?: 3)
            end
          end

          context 'with valid input' do
            let(:input) { { 'foo' => %w[1 2 3] } }

            it 'is successful' do
              expect(result).to be_successful
            end
          end

          context 'with missing input' do
            let(:input) { {} }

            it 'is not successful' do
              expect(result).to be_failing ['is missing', 'must be an array or must be a string', 'size must be 3']
            end
          end

          context 'with nil input' do
            let(:input) { { 'foo' => nil } }

            it 'is not successful' do
              expect(result).to be_failing ['must be filled', 'size must be 3']
            end
          end

          context 'with blank input' do
            let(:input) { { 'foo' => '' } }

            it 'is not successful' do
              expect(result).to be_failing ['must be filled', 'size must be 3']
            end
          end

          context 'with invalid input' do
            let(:input) { { 'foo' => { 'a' => '1', 'b' => '2', 'c' => '3', 'd' => '4' } } }

            it 'is not successful' do
              expect(result).to be_failing ['must be an array or must be a string', 'size must be 3']
            end
          end
        end

        context 'with maybe' do
          subject(:schema) do
            Dry::Schema.Params do
              required(:foo).maybe([:integer, :string], size?: 3)
            end
          end

          context 'with valid input' do
            let(:input) { { 'foo' => 'bar' } }

            it 'is successful' do
              expect(result).to be_successful
            end
          end

          context 'with missing input' do
            let(:input) { {} }

            it 'is not successful' do
              expect(result).to be_failing ['is missing', 'must be an integer or must be a string', 'size must be 3']
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
              expect(result).to be_failing ['length must be 3']
            end
          end

          context 'with invalid input' do
            let(:input) { { 'foo' => { 'a' => '1', 'b' => '2', 'c' => '3', 'd' => '4' } } }

            it 'is not successful' do
              expect(result).to be_failing ['must be an integer or must be a string', 'size must be 3']
            end
          end
        end
      end

      context 'with optional' do
        context 'with value' do
          subject(:schema) do
            Dry::Schema.Params do
              optional(:foo).value([:integer, :string], size?: 3)
            end
          end

          context 'with valid input' do
            let(:input) { { 'foo' => 'bar' } }

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
              expect(result).to be_failing ['must be an integer or must be a string', 'size must be 3']
            end
          end

          context 'with blank input' do
            let(:input) { { 'foo' => '' } }

            it 'is not successful' do
              expect(result).to be_failing ['length must be 3']
            end
          end

          context 'with invalid input' do
            let(:input) { { 'foo' => { 'a' => '1', 'b' => '2', 'c' => '3', 'd' => '4' } } }

            it 'is not successful' do
              expect(result).to be_failing ['must be an integer or must be a string', 'size must be 3']
            end
          end
        end

        context 'with filled' do
          subject(:schema) do
            Dry::Schema.Params do
              optional(:foo).filled([:array, :string], size?: 3)
            end
          end

          context 'with valid input' do
            let(:input) { { 'foo' => %w[1 2 3] } }

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
              expect(result).to be_failing ['must be filled', 'size must be 3']
            end
          end

          context 'with blank input' do
            let(:input) { { 'foo' => '' } }

            it 'is not successful' do
              expect(result).to be_failing ['must be filled', 'size must be 3']
            end
          end

          context 'with invalid input' do
            let(:input) { { 'foo' => { 'a' => '1', 'b' => '2', 'c' => '3', 'd' => '4' } } }

            it 'is not successful' do
              expect(result).to be_failing ['must be an array or must be a string', 'size must be 3']
            end
          end
        end

        context 'with maybe' do
          subject(:schema) do
            Dry::Schema.Params do
              optional(:foo).maybe([:integer, :string], size?: 3)
            end
          end

          context 'with valid input' do
            let(:input) { { 'foo' => 'bar' } }

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
              expect(result).to be_failing ['length must be 3']
            end
          end

          context 'with invalid input' do
            let(:input) { { 'foo' => { 'a' => '1', 'b' => '2', 'c' => '3', 'd' => '4' } } }

            it 'is not successful' do
              expect(result).to be_failing ['must be an integer or must be a string', 'size must be 3']
            end
          end
        end
      end
    end
  end
end
