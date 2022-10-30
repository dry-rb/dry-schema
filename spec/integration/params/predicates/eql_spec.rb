# frozen_string_literal: true

RSpec.describe "Predicates: IsEql" do
  context "with required" do
    subject(:schema) do
      Dry::Schema.Params do
        required(:foo).value(:string) { is_eql?("23") }
      end
    end

    context "with valid input" do
      let(:input) { {"foo" => "23"} }

      it "is successful" do
        expect(result).to be_successful
      end
    end

    context "with missing input" do
      let(:input) { {} }

      it "is not successful" do
        expect(result).to be_failing ["is missing", "must be a string", "must be equal to 23"]
      end
    end

    context "with nil input" do
      let(:input) { {"foo" => nil} }

      it "is not successful" do
        expect(result).to be_failing ["must be a string", "must be equal to 23"]
      end
    end

    context "with blank input" do
      let(:input) { {"foo" => ""} }

      it "is not successful" do
        expect(result).to be_failing ["must be equal to 23"]
      end
    end
  end

  context "with optional" do
    subject(:schema) do
      Dry::Schema.Params do
        optional(:foo).value(:string) { is_eql?("23") }
      end
    end

    context "with valid input" do
      let(:input) { {"foo" => "23"} }

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
        expect(result).to be_failing ["must be a string", "must be equal to 23"]
      end
    end

    context "with blank input" do
      let(:input) { {"foo" => ""} }

      it "is not successful" do
        expect(result).to be_failing ["must be equal to 23"]
      end
    end
  end

  context "as macro" do
    context "with required" do
      context "with value" do
        subject(:schema) do
          Dry::Schema.Params do
            required(:foo).value(:string, is_eql?: "23")
          end
        end

        context "with valid input" do
          let(:input) { {"foo" => "23"} }

          it "is successful" do
            expect(result).to be_successful
          end
        end

        context "with missing input" do
          let(:input) { {} }

          it "is not successful" do
            expect(result).to be_failing ["is missing", "must be a string", "must be equal to 23"]
          end
        end

        context "with nil input" do
          let(:input) { {"foo" => nil} }

          it "is not successful" do
            expect(result).to be_failing ["must be a string", "must be equal to 23"]
          end
        end

        context "with blank input" do
          let(:input) { {"foo" => ""} }

          it "is not successful" do
            expect(result).to be_failing ["must be equal to 23"]
          end
        end
      end

      context "with filled" do
        subject(:schema) do
          Dry::Schema.Params do
            required(:foo).filled(:string, is_eql?: "23")
          end
        end

        context "with valid input" do
          let(:input) { {"foo" => "23"} }

          it "is successful" do
            expect(result).to be_successful
          end
        end

        context "with missing input" do
          let(:input) { {} }

          it "is not successful" do
            expect(result).to be_failing ["is missing", "must be a string", "must be equal to 23"]
          end
        end

        context "with nil input" do
          let(:input) { {"foo" => nil} }

          it "is not successful" do
            expect(result).to be_failing ["must be filled", "must be equal to 23"]
          end
        end

        context "with blank input" do
          let(:input) { {"foo" => ""} }

          it "is not successful" do
            expect(result).to be_failing ["must be filled", "must be equal to 23"]
          end
        end
      end

      context "with maybe" do
        subject(:schema) do
          Dry::Schema.Params do
            required(:foo).maybe(:string, is_eql?: "23")
          end
        end

        context "with valid input" do
          let(:input) { {"foo" => "23"} }

          it "is successful" do
            expect(result).to be_successful
          end
        end

        context "with missing input" do
          let(:input) { {} }

          it "is not successful" do
            expect(result).to be_failing ["is missing", "must be a string", "must be equal to 23"]
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
      end
    end

    context "with optional" do
      context "with value" do
        subject(:schema) do
          Dry::Schema.Params do
            optional(:foo).value(:string, is_eql?: "23")
          end
        end

        context "with valid input" do
          let(:input) { {"foo" => "23"} }

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
            expect(result).to be_failing ["must be a string", "must be equal to 23"]
          end
        end

        context "with blank input" do
          let(:input) { {"foo" => ""} }

          it "is not successful" do
            expect(result).to be_failing ["must be equal to 23"]
          end
        end
      end

      context "with filled" do
        subject(:schema) do
          Dry::Schema.Params do
            optional(:foo).filled(:string, is_eql?: "23")
          end
        end

        context "with valid input" do
          let(:input) { {"foo" => "23"} }

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
            expect(result).to be_failing ["must be filled", "must be equal to 23"]
          end
        end

        context "with blank input" do
          let(:input) { {"foo" => ""} }

          it "is not successful" do
            expect(result).to be_failing ["must be filled", "must be equal to 23"]
          end
        end
      end

      context "with maybe" do
        subject(:schema) do
          Dry::Schema.Params do
            optional(:foo).maybe(:string, is_eql?: "23")
          end
        end

        context "with valid input" do
          let(:input) { {"foo" => "23"} }

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
      end
    end
  end
end
