# frozen_string_literal: true

RSpec.describe 'Verifying predicates in the DSL' do
  it 'raises error when invalid predicate name is used' do
    expect { Dry::Schema.define { required(:age).value(filled?: 312) } }
      .to raise_error(ArgumentError, "filled? predicate arity is invalid")

    expect { Dry::Schema.define { required(:age) { nil? | filled?(312) } } }
      .to raise_error(ArgumentError, "filled? predicate arity is invalid")

    expect { Dry::Schema.define { required(:age).value(:oops?) } }
      .to raise_error(ArgumentError, "oops? predicate is not defined")
  end
end
