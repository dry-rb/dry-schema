# frozen_string_literal: true

RSpec.describe "Predicates: Excludes" do
  context "with required" do
    subject(:schema) do
      Dry::Schema.Params do
        required(:foo).value(array[:integer]).each(:integer).value(excludes?: 1)
      end
    end

    context "with valid input" do
      let(:input) { {"foo" => %w[2 3 4]} }

      it "is successful" do
        expect(result).to be_successful
      end
    end

    context "with missing input" do
      let(:input) { {} }

      it "is not successful" do
        expect(result).to be_failing ["is missing", "must be an array", "must not include 1"]
      end
    end

    context "with nil input" do
      let(:input) { {"foo" => nil} }

      it "is not successful" do
        expect(result).to be_failing ["must be an array", "must not include 1"]
      end
    end

    context "with blank input" do
      let(:input) { {"foo" => ""} }

      it "is successful" do
        expect(result).to be_successful
      end
    end

    context "with invalid input" do
      let(:input) { {"foo" => %w[1 2 3]} }

      it "is not successful" do
        expect(result).to be_failing ["must not include 1"]
      end
    end
  end

  context "with optional" do
    subject(:schema) do
      Dry::Schema.Params do
        optional(:foo).value(array[:integer]).each(:integer).value(excludes?: 1)
      end
    end

    context "with valid input" do
      let(:input) { {"foo" => %w[2 3 4]} }

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
        expect(result).to be_failing ["must be an array", "must not include 1"]
      end
    end

    context "with blank input" do
      let(:input) { {"foo" => ""} }

      it "is successful" do
        expect(result).to be_successful
      end
    end

    context "with invalid input" do
      let(:input) { {"foo" => %w[1 2 3]} }

      it "is not successful" do
        expect(result).to be_failing ["must not include 1"]
      end
    end
  end

  context "as macro" do
    context "with required" do
      context "with value" do
        subject(:schema) do
          Dry::Schema.Params do
            required(:foo).value(:string, excludes?: "foo")
          end
        end

        context "with valid input" do
          let(:input) { {"foo" => "bar"} }

          it "is successful" do
            expect(result).to be_successful
          end
        end

        context "with missing input" do
          let(:input) { {} }

          it "is not successful" do
            expect(result).to be_failing ["is missing", "must be a string", "must not include foo"]
          end
        end

        context "with nil input" do
          let(:input) { {"foo" => nil} }

          it "is successful" do
            expect(result).to be_failing ["must be a string", "must not include foo"]
          end
        end

        context "with blank input" do
          let(:input) { {"foo" => ""} }

          it "is successful" do
            expect(result).to be_successful
          end
        end

        context "with invalid input" do
          let(:input) { {"foo" => "foo"} }

          it "is not successful" do
            expect(result).to be_failing ["must not include foo"]
          end
        end
      end

      context "with filled" do
        subject(:schema) do
          Dry::Schema.Params do
            required(:foo).filled(:string, excludes?: "foo")
          end
        end

        context "with valid input" do
          let(:input) { {"foo" => "Hello World"} }

          it "is successful" do
            expect(result).to be_successful
          end
        end

        context "with missing input" do
          let(:input) { {} }

          it "is not successful" do
            expect(result).to be_failing ["is missing", "must be a string", "must not include foo"]
          end
        end

        context "with nil input" do
          let(:input) { {"foo" => nil} }

          it "is not successful" do
            expect(result).to be_failing ["must be filled", "must not include foo"]
          end
        end

        context "with blank input" do
          let(:input) { {"foo" => ""} }

          it "is not successful" do
            expect(result).to be_failing ["must be filled", "must not include foo"]
          end
        end

        context "with invalid input" do
          let(:input) { {"foo" => "foo bar"} }

          it "is not successful" do
            expect(result).to be_failing ["must not include foo"]
          end
        end
      end

      context "with maybe" do
        subject(:schema) do
          Dry::Schema.Params do
            required(:foo).maybe(:string, excludes?: "foo")
          end
        end

        context "with valid input" do
          let(:input) { {"foo" => "Hello World"} }

          it "is successful" do
            expect(result).to be_successful
          end
        end

        context "with missing input" do
          let(:input) { {} }

          it "is not successful" do
            expect(result).to be_failing ["is missing", "must be a string", "must not include foo"]
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
          let(:input) { {"foo" => "foo bar"} }

          it "is not successful" do
            expect(result).to be_failing ["must not include foo"]
          end
        end
      end
    end

    context "with optional" do
      context "with value" do
        subject(:schema) do
          Dry::Schema.Params do
            optional(:foo).value(array[:integer], excludes?: 1)
          end
        end

        context "with valid input" do
          let(:input) { {"foo" => %w[2 3 4]} }

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
            expect(result).to be_failing ["must be an array", "must not include 1"]
          end
        end

        context "with blank input" do
          let(:input) { {"foo" => ""} }

          it "is successful" do
            expect(result).to be_successful
          end
        end

        context "with invalid input" do
          let(:input) { {"foo" => %w[1 2 3]} }

          it "is not successful" do
            expect(result).to be_failing ["must not include 1"]
          end
        end
      end

      context "with filled" do
        subject(:schema) do
          Dry::Schema.Params do
            optional(:foo).filled(:string, excludes?: "foo")
          end
        end

        context "with valid input" do
          let(:input) { {"foo" => "bar"} }

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
            expect(result).to be_failing ["must be filled", "must not include foo"]
          end
        end

        context "with blank input" do
          let(:input) { {"foo" => ""} }

          it "is not successful" do
            expect(result).to be_failing ["must be filled", "must not include foo"]
          end
        end

        context "with invalid input" do
          let(:input) { {"foo" => "foo"} }

          it "is not successful" do
            expect(result).to be_failing ["must not include foo"]
          end
        end
      end

      context "with maybe" do
        subject(:schema) do
          Dry::Schema.Params do
            optional(:foo).maybe(:string, excludes?: "foo")
          end
        end

        context "with valid input" do
          let(:input) { {"foo" => "bar"} }

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
          let(:input) { {"foo" => "foo"} }

          it "is not successful" do
            expect(result).to be_failing ["must not include foo"]
          end
        end
      end
    end
  end
end
