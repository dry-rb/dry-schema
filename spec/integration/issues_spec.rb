# frozen_string_literal: true

RSpec.describe "GitHub issues" do
  describe "dry-rb/dry-validation#718" do
    let(:schema) do
      Dry::Schema.Params do
        optional(:results).maybe(:hash) do
          optional(:tours).value(:array).each do
            hash do
              required(:last_stop_ends_at).filled(:date_time)
              required(:stops).value(:array).each do
                hash do
                  optional(:id).filled(:integer)
                  required(:starts_at).filled(:date_time)
                end
              end
            end
          end
        end
      end
    end

    specify do
      params = {
        results: {
          tours: [
            {
              last_stop_ends_at: "2020-05-13T09:45:42+00:00",
              stops: [{starts_at: "2020-05-13T08:00:00+00:00"}]
            }
          ]
        }
      }

      result = schema.call(params)
      expect(result).to be_success
      expect(result.to_h).to eq(
        {
          results: {
            tours: [{
              last_stop_ends_at: DateTime.new(2020, 5, 13, 9, 45, 42),
              stops: [{
                starts_at: DateTime.new(2020, 5, 13, 8)
              }]
            }]
          }
        }
      )
    end
  end

  describe "dry-rb/dry-schema#423" do
    let(:type_container) do
      Dry::Schema::TypeContainer.new
    end

    subject(:schema) do
      type_container = self.type_container
      Dry::Schema.Params do
        config.types = type_container
        optional(:date).maybe(:calendar_day)
      end
    end

    let(:calendar_date) do
      Class.new(::Date) do
        def to_json(*args)
          strftime("--%m-%d").to_json(*args)
        end

        def self.parse(date)
          mon, mday = Date._iso8601(date).values_at(:mon, :mday)
          raise ArgumentError, "invalid ISO8601 calendar day string, expected format \"--MM-DD\"" unless mon && mday

          new(2000, mon, mday)
        end
      end
    end

    before do
      stub_const("CalendarDate", calendar_date)

      type_container.register(
        :calendar_day,
        Types::Strict(CalendarDate).constructor(CalendarDate.method(:parse))
      )
    end

    let(:params) do
      {"date" => "--02-09"}
    end

    specify do
      result = schema.call(params)
      expect(result).to be_success
      expect(result[:date]).to be_a(CalendarDate)
      expect(result[:date].to_json).to eq('"--02-09"')
    end
  end
end
