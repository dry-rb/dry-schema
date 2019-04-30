# frozen_string_literal: true

require 'dry/schema/predicate_inferrer'
require 'dry/schema/predicate_registry'

RSpec.describe Dry::Schema::PredicateInferrer, '#[]' do
  subject(:inferrer) do
    Dry::Schema::PredicateInferrer.new(Dry::Schema::PredicateRegistry.new)
  end

  def type(*args)
    args.map { |name| Dry::Types[name.to_s] }.reduce(:|)
  end

  it 'caches results' do
    expect(inferrer[type(:string)]).to be(inferrer[type(:string)])
  end

  it 'returns str? for a string type' do
    expect(inferrer[type(:string)]).to eql([:str?])
  end

  it 'returns int? for a integer type' do
    expect(inferrer[type(:integer)]).to eql([:int?])
  end

  it 'returns date_time? for a datetime type' do
    expect(inferrer[type(:date_time)]).to eql([:date_time?])
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

  it 'returns bool? for bool type' do
    expect(inferrer[type(:bool)]).to eql([:bool?])
  end

  it 'returns int? for a lax constructor integer type' do
    expect(inferrer[type('params.integer').lax]).to eql([:int?])
  end

  it 'returns :int? from an optional integer with constructor' do
    expect(inferrer[type(:integer).optional.constructor(&:to_i)]).to eql([:int?])
  end

  it 'returns int? for integer enum type' do
    expect(inferrer[type(:integer).enum(1, 2)]).to eql([:int?])
  end

  it 'returns type?(type) for arbitrary types' do
    custom_type = Dry::Types::Nominal.new(double(:some_type, name: 'ObjectID'))

    expect(inferrer[custom_type]).to eql(type?: custom_type.primitive)
  end

  it 'returns nothing for any' do
    expect(inferrer[type(:any)]).to eql([])
  end
end
