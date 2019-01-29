require 'dry/schema/predicate_inferrer'

RSpec.describe Dry::Schema::PredicateInferrer, '#[]' do
  subject(:inferrer) { Dry::Schema::PredicateInferrer }

  def type(*args)
    args.map { |name| Dry::Types[name.to_s] }.reduce(:|)
  end

  it 'returns str? for a string type' do
    expect(inferrer[type(:string)]).to eql([:str?])
  end

  it 'returns int? for a integer type' do
    expect(inferrer[type(:integer)]).to eql([:int?])
  end

  it 'returns nil? for a nil type' do
    expect(inferrer[type(:nil)]).to eql([:nil?])
  end

  it 'returns false? for a false type' do
    expect(inferrer[type(:false)]).to eql([:false?])
  end

  it 'returns true? for a true type' do
    expect(inferrer[type(:true)]).to eql([:true?])
  end

  it 'returns false? for a false type' do
    expect(inferrer[type(:false)]).to eql([:false?])
  end
end