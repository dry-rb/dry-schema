# frozen_string_literal: true

RSpec.describe "Predicates: Bytesize" do
  context "Fixed (integer)" do
    context "with required" do
      subject(:schema) do
        Dry::Schema.define do
          required(:foo) { bytesize?(3) }
        end
      end

      context "with valid input" do
        let(:input) { {foo: "こ"} }

        it "is successful" do
          expect(result).to be_successful
        end
      end

      context "with missing input" do
        let(:input) { {} }

        it "is not successful" do
          expect(result).to be_failing ["is missing", "must be 3 bytes long"]
        end
      end

      context "with nil input" do
        let(:input) { {foo: nil} }

        it "is raises error" do
          expect { result }.to raise_error(NoMethodError)
        end
      end

      context "with blank input" do
        let(:input) { {foo: ""} }

        it "is not successful" do
          expect(result).to be_failing ["must be 3 bytes long"]
        end
      end

      context "with invalid input" do
        let(:input) { {foo: "こa"} }

        it "is not successful" do
          expect(result).to be_failing ["must be 3 bytes long"]
        end
      end
    end

    context "with optional" do
      subject(:schema) do
        Dry::Schema.define do
          optional(:foo) { bytesize?(3) }
        end
      end

      context "with valid input" do
        let(:input) { {foo: "こ"} }

        it "is successful" do
          expect(result).to be_successful
        end
      end

      context "with missing input" do
        let(:input) { {} }

        it "is successful" do
          expect(result).to be_successful
        end
      end

      context "with nil input" do
        let(:input) { {foo: nil} }

        it "is raises error" do
          expect { result }.to raise_error(NoMethodError)
        end
      end

      context "with blank input" do
        let(:input) { {foo: ""} }

        # see: https://github.com/dry-rb/dry-validation/issues/121
        it "is not successful" do
          expect(result).to be_failing ["must be 3 bytes long"]
        end
      end

      context "with invalid input" do
        let(:input) { {foo: "こa"} }

        it "is not successful" do
          expect(result).to be_failing ["must be 3 bytes long"]
        end
      end
    end

    context "as macro" do
      context "with required" do
        context "with value" do
          subject(:schema) do
            Dry::Schema.define do
              required(:foo).value(bytesize?: 3)
            end
          end

          context "with valid input" do
            let(:input) { {foo: "こ"} }

            it "is successful" do
              expect(result).to be_successful
            end
          end

          context "with missing input" do
            let(:input) { {} }

            it "is not successful" do
              expect(result).to be_failing ["is missing", "must be 3 bytes long"]
            end
          end

          context "with nil input" do
            let(:input) { {foo: nil} }

            it "is raises error" do
              expect { result }.to raise_error(NoMethodError)
            end
          end

          context "with blank input" do
            let(:input) { {foo: ""} }

            # see: https://github.com/dry-rb/dry-validation/issues/121
            it "is not successful" do
              expect(result).to be_failing ["must be 3 bytes long"]
            end
          end

          context "with invalid input" do
            let(:input) { {foo: "こa"} }

            it "is not successful" do
              expect(result).to be_failing ["must be 3 bytes long"]
            end
          end
        end

        context "with filled" do
          subject(:schema) do
            Dry::Schema.define do
              required(:foo).filled(bytesize?: 3)
            end
          end

          context "with valid input" do
            let(:input) { {foo: "こ"} }

            it "is successful" do
              expect(result).to be_successful
            end
          end

          context "with missing input" do
            let(:input) { {} }

            it "is not successful" do
              expect(result).to be_failing ["is missing", "must be 3 bytes long"]
            end
          end

          context "with nil input" do
            let(:input) { {foo: nil} }

            it "is not successful" do
              expect(result).to be_failing ["must be filled", "must be 3 bytes long"]
            end
          end

          context "with blank input" do
            let(:input) { {foo: ""} }

            it "is not successful" do
              expect(result).to be_failing ["must be filled", "must be 3 bytes long"]
            end
          end

          context "with invalid input" do
            let(:input) { {foo: "こa"} }

            it "is not successful" do
              expect(result).to be_failing ["must be 3 bytes long"]
            end
          end
        end

        context "with maybe" do
          subject(:schema) do
            Dry::Schema.define do
              required(:foo).maybe(bytesize?: 3)
            end
          end

          context "with valid input" do
            let(:input) { {foo: "こ"} }

            it "is successful" do
              expect(result).to be_successful
            end
          end

          context "with missing input" do
            let(:input) { {} }

            it "is not successful" do
              expect(result).to be_failing ["is missing", "must be 3 bytes long"]
            end
          end

          context "with nil input" do
            let(:input) { {foo: nil} }

            it "is successful" do
              expect(result).to be_successful
            end
          end

          context "with blank input" do
            let(:input) { {foo: ""} }

            # see: https://github.com/dry-rb/dry-validation/issues/121
            it "is not successful" do
              expect(result).to be_failing ["must be 3 bytes long"]
            end
          end

          context "with invalid input" do
            let(:input) { {foo: "こa"} }

            it "is not successful" do
              expect(result).to be_failing ["must be 3 bytes long"]
            end
          end
        end
      end

      context "with optional" do
        context "with value" do
          subject(:schema) do
            Dry::Schema.define do
              optional(:foo).value(bytesize?: 3)
            end
          end

          context "with valid input" do
            let(:input) { {foo: "こ"} }

            it "is successful" do
              expect(result).to be_successful
            end
          end

          context "with missing input" do
            let(:input) { {} }

            it "is successful" do
              expect(result).to be_successful
            end
          end

          context "with nil input" do
            let(:input) { {foo: nil} }

            it "is raises error" do
              expect { result }.to raise_error(NoMethodError)
            end
          end

          context "with blank input" do
            let(:input) { {foo: ""} }

            # see: https://github.com/dry-rb/dry-validation/issues/121
            it "is not successful" do
              expect(result).to be_failing ["must be 3 bytes long"]
            end
          end

          context "with invalid input" do
            let(:input) { {foo: "こa"} }

            it "is not successful" do
              expect(result).to be_failing ["must be 3 bytes long"]
            end
          end
        end

        context "with filled" do
          subject(:schema) do
            Dry::Schema.define do
              optional(:foo).filled(bytesize?: 3)
            end
          end

          context "with valid input" do
            let(:input) { {foo: "こ"} }

            it "is successful" do
              expect(result).to be_successful
            end
          end

          context "with missing input" do
            let(:input) { {} }

            it "is successful" do
              expect(result).to be_successful
            end
          end

          context "with nil input" do
            let(:input) { {foo: nil} }

            it "is not successful" do
              expect(result).to be_failing ["must be filled", "must be 3 bytes long"]
            end
          end

          context "with blank input" do
            let(:input) { {foo: ""} }

            it "is not successful" do
              expect(result).to be_failing ["must be filled", "must be 3 bytes long"]
            end
          end

          context "with invalid input" do
            let(:input) { {foo: "こa"} }

            it "is not successful" do
              expect(result).to be_failing ["must be 3 bytes long"]
            end
          end
        end

        context "with maybe" do
          subject(:schema) do
            Dry::Schema.define do
              optional(:foo).maybe(bytesize?: 3)
            end
          end

          context "with valid input" do
            let(:input) { {foo: "こ"} }

            it "is successful" do
              expect(result).to be_successful
            end
          end

          context "with missing input" do
            let(:input) { {} }

            it "is successful" do
              expect(result).to be_successful
            end
          end

          context "with nil input" do
            let(:input) { {foo: nil} }

            it "is successful" do
              expect(result).to be_successful
            end
          end

          context "with blank input" do
            let(:input) { {foo: ""} }

            # see: https://github.com/dry-rb/dry-validation/issues/121
            it "is not successful" do
              expect(result).to be_failing ["must be 3 bytes long"]
            end
          end

          context "with invalid input" do
            let(:input) { {foo: "こa"} }

            it "is not successful" do
              expect(result).to be_failing ["must be 3 bytes long"]
            end
          end
        end
      end
    end
  end
end
