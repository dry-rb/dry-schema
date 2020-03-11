# frozen_string_literal: true

RSpec.describe "Predicates: Max Bytesize" do
  context "with required" do
    subject(:schema) do
      Dry::Schema.Params do
        required(:foo) { max_bytesize?(3) }
      end
    end

    context "with valid input" do
      let(:input) { {"foo" => "ab"} }

      it "is successful" do
        expect(result).to be_successful
      end
    end

    context "with missing input" do
      let(:input) { {} }

      it "is not successful" do
        expect(result).to be_failing ["is missing", "bytesize cannot be greater than 3"]
      end
    end

    context "with nil input" do
      let(:input) { {"foo" => nil} }

      it "is raises error" do
        expect { result }.to raise_error(NoMethodError)
      end
    end

    context "with blank input" do
      let(:input) { {"foo" => ""} }

      it "is successful" do
        expect(result).to be_successful
      end
    end

    context "with invalid input" do
      let(:input) { {"foo" => "こa"} }

      it "is not successful" do
        expect(result).to be_failing ["bytesize cannot be greater than 3"]
      end
    end
  end

  context "with optional" do
    subject(:schema) do
      Dry::Schema.Params do
        optional(:foo) { max_bytesize?(3) }
      end
    end

    context "with valid input" do
      let(:input) { {"foo" => "ab"} }

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
      let(:input) { {"foo" => nil} }

      it "is raises error" do
        expect { result }.to raise_error(NoMethodError)
      end
    end

    context "with blank input" do
      let(:input) { {"foo" => ""} }

      it "is successful" do
        expect(result).to be_successful
      end
    end

    context "with invalid input" do
      let(:input) { {"foo" => "こa"} }

      it "is not successful" do
        expect(result).to be_failing ["bytesize cannot be greater than 3"]
      end
    end
  end

  context "as macro" do
    context "with required" do
      context "with value" do
        subject(:schema) do
          Dry::Schema.Params do
            required(:foo).value(max_bytesize?: 3)
          end
        end

        context "with valid input" do
          let(:input) { {"foo" => "ab"} }

          it "is successful" do
            expect(result).to be_successful
          end
        end

        context "with missing input" do
          let(:input) { {} }

          it "is not successful" do
            expect(result).to be_failing ["is missing", "bytesize cannot be greater than 3"]
          end
        end

        context "with nil input" do
          let(:input) { {"foo" => nil} }

          it "is not successful" do
            expect { result }.to raise_error(NoMethodError)
          end
        end

        context "with blank input" do
          let(:input) { {"foo" => ""} }

          it "is successful" do
            expect(result).to be_successful
          end
        end

        context "with invalid input" do
          let(:input) { {"foo" => "こa"} }

          it "is not successful" do
            expect(result).to be_failing ["bytesize cannot be greater than 3"]
          end
        end
      end

      context "with filled" do
        subject(:schema) do
          Dry::Schema.Params do
            required(:foo).filled(max_bytesize?: 3)
          end
        end

        context "with valid input" do
          let(:input) { {"foo" => "ab"} }

          it "is successful" do
            expect(result).to be_successful
          end
        end

        context "with missing input" do
          let(:input) { {} }

          it "is not successful" do
            expect(result).to be_failing ["is missing", "bytesize cannot be greater than 3"]
          end
        end

        context "with nil input" do
          let(:input) { {"foo" => nil} }

          it "is not successful" do
            expect(result).to be_failing ["must be filled", "bytesize cannot be greater than 3"]
          end
        end

        context "with blank input" do
          let(:input) { {"foo" => ""} }

          it "is not successful" do
            expect(result).to be_failing ["must be filled", "bytesize cannot be greater than 3"]
          end
        end

        context "with invalid input" do
          let(:input) { {"foo" => "こa"} }

          it "is not successful" do
            expect(result).to be_failing ["bytesize cannot be greater than 3"]
          end
        end
      end

      context "with maybe" do
        subject(:schema) do
          Dry::Schema.Params do
            required(:foo).maybe(max_bytesize?: 3)
          end
        end

        context "with valid input" do
          let(:input) { {"foo" => "ab"} }

          it "is successful" do
            expect(result).to be_successful
          end
        end

        context "with missing input" do
          let(:input) { {} }

          it "is not successful" do
            expect(result).to be_failing ["is missing", "bytesize cannot be greater than 3"]
          end
        end

        context "with nil input" do
          let(:input) { {"foo" => nil} }

          it "is successful" do
            expect(result).to be_successful
          end
        end

        context "with blank input" do
          let(:input) { {"foo" => ""} }

          it "is successful" do
            expect(result).to be_successful
          end
        end

        context "with invalid input" do
          let(:input) { {"foo" => "こa"} }

          it "is not successful" do
            expect(result).to be_failing ["bytesize cannot be greater than 3"]
          end
        end
      end
    end

    context "with optional" do
      context "with value" do
        subject(:schema) do
          Dry::Schema.Params do
            optional(:foo).value(max_bytesize?: 3)
          end
        end

        context "with valid input" do
          let(:input) { {"foo" => "ab"} }

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
          let(:input) { {"foo" => nil} }

          it "is raises error" do
            expect { result }.to raise_error(NoMethodError)
          end
        end

        context "with blank input" do
          let(:input) { {"foo" => ""} }

          it "is successful" do
            expect(result).to be_successful
          end
        end

        context "with invalid input" do
          let(:input) { {"foo" => "こa"} }

          it "is not successful" do
            expect(result).to be_failing ["bytesize cannot be greater than 3"]
          end
        end
      end

      context "with filled" do
        subject(:schema) do
          Dry::Schema.Params do
            optional(:foo).filled(max_bytesize?: 3)
          end
        end

        context "with valid input" do
          let(:input) { {"foo" => "ab"} }

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
          let(:input) { {"foo" => nil} }

          it "is not successful" do
            expect(result).to be_failing ["must be filled", "bytesize cannot be greater than 3"]
          end
        end

        context "with blank input" do
          let(:input) { {"foo" => ""} }

          it "is not successful" do
            expect(result).to be_failing ["must be filled", "bytesize cannot be greater than 3"]
          end
        end

        context "with invalid input" do
          let(:input) { {"foo" => "こa"} }

          it "is not successful" do
            expect(result).to be_failing ["bytesize cannot be greater than 3"]
          end
        end
      end

      context "with maybe" do
        subject(:schema) do
          Dry::Schema.Params do
            optional(:foo).maybe(max_bytesize?: 3)
          end
        end

        context "with valid input" do
          let(:input) { {"foo" => "ab"} }

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
          let(:input) { {"foo" => nil} }

          it "is successful" do
            expect(result).to be_successful
          end
        end

        context "with blank input" do
          let(:input) { {"foo" => ""} }

          it "is successful" do
            expect(result).to be_successful
          end
        end

        context "with invalid input" do
          let(:input) { {"foo" => "こa"} }

          it "is not successful" do
            expect(result).to be_failing ["bytesize cannot be greater than 3"]
          end
        end
      end
    end
  end
end
