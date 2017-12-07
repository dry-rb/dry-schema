RSpec.describe 'Building schemas' do
  describe 'Dry::Schema.build' do
    it 'builds a schema class with custom predicate set' do
      predicates = Module.new do
        include Dry::Logic::Predicates

        def zomg?(*)
          true
        end
      end

      schema = Dry::Schema.build(predicates: predicates, build: false)

      expect(schema.predicates[:key?]).to be_a(Method)
    end
  end
end
