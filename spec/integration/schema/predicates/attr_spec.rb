# frozen_string_literal: true

RSpec.describe "Predicates: Attr" do
  context "with required" do
    subject(:schema) do
      Dry::Schema.define do
        required(:foo) { attr?(:to_i) }
      end
    end

    context "with valid input" do
      let(:input) { {foo: 42} }

      it "is successful" do
        expect(result).to be_successful
      end
    end

    context "with missing input" do
      let(:input) { {} }

      it "is not successful" do
        expect(result).to be_failing ["is missing", "must respond to to_i"]
      end
    end

    context "with input that does not respond to method" do
      let(:input) { {foo: Object.new} }

      it "is not successful" do
        expect(result).to be_failing ["must respond to to_i"]
      end
    end
  end

  context "with optional" do
    subject(:schema) do
      Dry::Schema.define do
        optional(:foo) { attr?(:to_i) }
      end
    end

    context "with valid input" do
      let(:input) { {foo: 42} }

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

    context "with input that does not respond to method" do
      let(:input) { {foo: Object.new} }

      it "is not successful" do
        expect(result).to be_failing ["must respond to to_i"]
      end
    end
  end

  context "as macro" do
    context "with required" do
      context "with value" do
        subject(:schema) do
          Dry::Schema.define do
            required(:foo).value(attr?: :to_i)
          end
        end

        context "with valid input" do
          let(:input) { {foo: 42} }

          it "is successful" do
            expect(result).to be_successful
          end
        end

        context "with missing input" do
          let(:input) { {} }

          it "is not successful" do
            expect(result).to be_failing ["is missing", "must respond to to_i"]
          end
        end

        context "with input that does not respond to method" do
          let(:input) { {foo: Object.new} }

          it "is not successful" do
            expect(result).to be_failing ["must respond to to_i"]
          end
        end
      end

      context "with filled" do
        subject(:schema) do
          Dry::Schema.define do
            required(:foo).filled(attr?: :to_i)
          end
        end

        context "with valid input" do
          let(:input) { {foo: 42} }

          it "is successful" do
            expect(result).to be_successful
          end
        end

        context "with missing input" do
          let(:input) { {} }

          it "is not successful" do
            expect(result).to be_failing ["is missing", "must respond to to_i"]
          end
        end

        context "with input that does not respond to method" do
          let(:input) { {foo: Object.new} }

          it "is not successful" do
            expect(result).to be_failing ["must respond to to_i"]
          end
        end
      end

      context "with maybe" do
        subject(:schema) do
          Dry::Schema.define do
            required(:foo).maybe(attr?: :to_i)
          end
        end

        context "with valid input" do
          let(:input) { {foo: 42} }

          it "is successful" do
            expect(result).to be_successful
          end
        end

        context "with missing input" do
          let(:input) { {} }

          it "is not successful" do
            expect(result).to be_failing ["is missing", "must respond to to_i"]
          end
        end

        context "with input that does not respond to method" do
          let(:input) { {foo: Object.new} }

          it "is not successful" do
            expect(result).to be_failing ["must respond to to_i"]
          end
        end
      end
    end

    context "with optional" do
      context "with value" do
        subject(:schema) do
          Dry::Schema.define do
            optional(:foo).value(attr?: :to_i)
          end
        end

        context "with valid input" do
          let(:input) { {foo: 42} }

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

        context "with input that does not respond to method" do
          let(:input) { {foo: Object.new} }

          it "is not successful" do
            expect(result).to be_failing ["must respond to to_i"]
          end
        end
      end

      context "with filled" do
        subject(:schema) do
          Dry::Schema.define do
            optional(:foo).filled(attr?: :to_i)
          end
        end

        context "with valid input" do
          let(:input) { {foo: 42} }

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

        context "with input that does not respond to method" do
          let(:input) { {foo: Object.new} }

          it "is not successful" do
            expect(result).to be_failing ["must respond to to_i"]
          end
        end
      end

      context "with maybe" do
        subject(:schema) do
          Dry::Schema.define do
            optional(:foo).maybe(attr?: :to_i)
          end
        end

        context "with valid input" do
          let(:input) { {foo: 42} }

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

        context "with input that does not respond to method" do
          let(:input) { {foo: Object.new} }

          it "is not successful" do
            expect(result).to be_failing ["must respond to to_i"]
          end
        end
      end
    end
  end
end
