# frozen_string_literal: true

require "dry/schema/trace"

RSpec.describe Dry::Schema::Trace do
  subject(:trace) { Dry::Schema::Trace.new }

  describe "#evaluate" do
    it "stores evaluated predicates" do
      trace.evaluate(:filled?)

      expect(trace.captures).to include(trace.filled?)
    end

    it "stores evaluated predicates with args" do
      trace.evaluate(eql?: "foo")

      expect(trace.captures).to include(trace.eql?("foo"))
    end
  end

  describe "#method_missing" do
    it "creates predicate objects" do
      predicate = trace.eql?("foo")

      expect(predicate.name).to be(:eql?)
      expect(predicate.args).to eql(["foo"])
    end

    it "raises NoMethodError when appriopriate" do
      expect { trace.not_here }.to raise_error(NoMethodError, /not_here/)
    end
  end

  describe "#respond_to?" do
    let(:respond_to) do
      Kernel.instance_method(:respond_to?)
    end

    it "returns true for predicates" do
      expect(respond_to.bind_call(trace, :eql?)).to be(true)
    end

    it "returns false for other methods" do
      expect(respond_to.bind_call(trace, :not_here?)).to be(false)
    end
  end
end
