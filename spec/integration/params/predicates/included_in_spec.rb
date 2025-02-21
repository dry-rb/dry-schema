# frozen_string_literal: true

RSpec.describe "Predicates: Included In" do
  context "with required" do
    let(:list) { %w[1 3 5] }

    subject(:schema) do
      list = self.list

      Dry::Schema.Params do
        required(:foo) { included_in?(list) }
      end
    end

    context "with valid input" do
      let(:input) { {"foo" => "3"} }

      it "is successful" do
        expect(result).to be_successful
      end
    end

    context "with missing input" do
      let(:input) { {} }

      it "is not successful" do
        expect(result).to be_failing ["is missing", "must be one of: 1, 3, 5"]
      end

      context "when list is a set" do
        let(:list) { Set.new(%w[1 3 5]) }

        it "is not successful" do
          expect(result).to be_failing ["is missing", "must be one of: 1, 3, 5"]
        end
      end
    end

    context "with nil input" do
      let(:input) { {"foo" => nil} }

      it "is not successful" do
        expect(result).to be_failing ["must be one of: 1, 3, 5"]
      end
    end

    context "with blank input" do
      let(:input) { {"foo" => ""} }

      it "is not successful" do
        expect(result).to be_failing ["must be one of: 1, 3, 5"]
      end
    end

    context "with invalid type" do
      let(:input) { {"foo" => {"a" => "1"}} }

      it "is not successful" do
        expect(result).to be_failing ["must be one of: 1, 3, 5"]
      end
    end

    context "with invalid input" do
      let(:input) { {"foo" => "4"} }

      it "is not successful" do
        expect(result).to be_failing ["must be one of: 1, 3, 5"]
      end
    end
  end

  context "with optional" do
    subject(:schema) do
      Dry::Schema.Params do
        optional(:foo) { included_in?(%w[1 3 5]) }
      end
    end

    context "with valid input" do
      let(:input) { {"foo" => "3"} }

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
        expect(result).to be_failing ["must be one of: 1, 3, 5"]
      end
    end

    context "with blank input" do
      let(:input) { {"foo" => ""} }

      it "is not successful" do
        expect(result).to be_failing ["must be one of: 1, 3, 5"]
      end
    end

    context "with invalid type" do
      let(:input) { {"foo" => {"a" => "1"}} }

      it "is not successful" do
        expect(result).to be_failing ["must be one of: 1, 3, 5"]
      end
    end

    context "with invalid input" do
      let(:input) { {"foo" => "4"} }

      it "is not successful" do
        expect(result).to be_failing ["must be one of: 1, 3, 5"]
      end
    end
  end

  context "as macro" do
    context "with required" do
      context "with value" do
        subject(:schema) do
          Dry::Schema.Params do
            required(:foo).value(included_in?: %w[1 3 5])
          end
        end

        context "with valid input" do
          let(:input) { {"foo" => "3"} }

          it "is successful" do
            expect(result).to be_successful
          end
        end

        context "with missing input" do
          let(:input) { {} }

          it "is not successful" do
            expect(result).to be_failing ["is missing", "must be one of: 1, 3, 5"]
          end
        end

        context "with nil input" do
          let(:input) { {"foo" => nil} }

          it "is not successful" do
            expect(result).to be_failing ["must be one of: 1, 3, 5"]
          end
        end

        context "with blank input" do
          let(:input) { {"foo" => ""} }

          it "is not successful" do
            expect(result).to be_failing ["must be one of: 1, 3, 5"]
          end
        end

        context "with invalid type" do
          let(:input) { {"foo" => {"a" => "1"}} }

          it "is not successful" do
            expect(result).to be_failing ["must be one of: 1, 3, 5"]
          end
        end

        context "with invalid input" do
          let(:input) { {"foo" => "4"} }

          it "is not successful" do
            expect(result).to be_failing ["must be one of: 1, 3, 5"]
          end
        end
      end

      context "with filled" do
        subject(:schema) do
          Dry::Schema.Params do
            required(:foo).filled(included_in?: %w[1 3 5])
          end
        end

        context "with valid input" do
          let(:input) { {"foo" => "3"} }

          it "is successful" do
            expect(result).to be_successful
          end
        end

        context "with missing input" do
          let(:input) { {} }

          it "is not successful" do
            expect(result).to be_failing ["is missing", "must be one of: 1, 3, 5"]
          end
        end

        context "with nil input" do
          let(:input) { {"foo" => nil} }

          it "is not successful" do
            expect(result).to be_failing ["must be filled", "must be one of: 1, 3, 5"]
          end
        end

        context "with blank input" do
          let(:input) { {"foo" => ""} }

          it "is not successful" do
            expect(result).to be_failing ["must be filled", "must be one of: 1, 3, 5"]
          end
        end

        context "with invalid type" do
          let(:input) { {"foo" => {"a" => "1"}} }

          it "is not successful" do
            expect(result).to be_failing ["must be one of: 1, 3, 5"]
          end
        end

        context "with invalid input" do
          let(:input) { {"foo" => "4"} }

          it "is not successful" do
            expect(result).to be_failing ["must be one of: 1, 3, 5"]
          end
        end
      end

      context "with maybe" do
        subject(:schema) do
          Dry::Schema.Params do
            required(:foo).maybe(:string, included_in?: %w[1 3 5])
          end
        end

        context "with valid input" do
          let(:input) { {"foo" => "3"} }

          it "is successful" do
            expect(result).to be_successful
          end
        end

        context "with missing input" do
          let(:input) { {} }

          it "is not successful" do
            expect(result).to be_failing ["is missing", "must be a string", "must be one of: 1, 3, 5"]
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

        context "with invalid type" do
          let(:input) { {"foo" => {"a" => "1"}} }

          it "is not successful" do
            expect(result).to be_failing ["must be a string", "must be one of: 1, 3, 5"]
          end
        end

        context "with invalid input" do
          let(:input) { {"foo" => "4"} }

          it "is not successful" do
            expect(result).to be_failing ["must be one of: 1, 3, 5"]
          end
        end
      end
    end

    context "with optional" do
      context "with value" do
        subject(:schema) do
          Dry::Schema.Params do
            optional(:foo).value(included_in?: %w[1 3 5])
          end
        end

        context "with valid input" do
          let(:input) { {"foo" => "3"} }

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
            expect(result).to be_failing ["must be one of: 1, 3, 5"]
          end
        end

        context "with blank input" do
          let(:input) { {"foo" => ""} }

          it "is not successful" do
            expect(result).to be_failing ["must be one of: 1, 3, 5"]
          end
        end

        context "with invalid type" do
          let(:input) { {"foo" => {"a" => "1"}} }

          it "is not successful" do
            expect(result).to be_failing ["must be one of: 1, 3, 5"]
          end
        end

        context "with invalid input" do
          let(:input) { {"foo" => "4"} }

          it "is not successful" do
            expect(result).to be_failing ["must be one of: 1, 3, 5"]
          end
        end
      end

      context "with filled" do
        subject(:schema) do
          Dry::Schema.Params do
            optional(:foo).filled(included_in?: %w[1 3 5])
          end
        end

        context "with valid input" do
          let(:input) { {"foo" => "3"} }

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
            expect(result).to be_failing ["must be filled", "must be one of: 1, 3, 5"]
          end
        end

        context "with blank input" do
          let(:input) { {"foo" => ""} }

          it "is not successful" do
            expect(result).to be_failing ["must be filled", "must be one of: 1, 3, 5"]
          end
        end

        context "with invalid type" do
          let(:input) { {"foo" => {"a" => "1"}} }

          it "is not successful" do
            expect(result).to be_failing ["must be one of: 1, 3, 5"]
          end
        end

        context "with invalid input" do
          let(:input) { {"foo" => "4"} }

          it "is not successful" do
            expect(result).to be_failing ["must be one of: 1, 3, 5"]
          end
        end
      end

      context "with maybe" do
        subject(:schema) do
          Dry::Schema.Params do
            optional(:foo).maybe(:string).maybe(included_in?: %w[1 3 5])
          end
        end

        context "with valid input" do
          let(:input) { {"foo" => "3"} }

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

        context "with invalid type" do
          let(:input) { {"foo" => {"a" => "1"}} }

          it "is not successful" do
            expect(result).to be_failing ["must be a string", "must be one of: 1, 3, 5"]
          end
        end

        context "with invalid input" do
          let(:input) { {"foo" => "4"} }

          it "is not successful" do
            expect(result).to be_failing ["must be one of: 1, 3, 5"]
          end
        end
      end
    end
  end
end
