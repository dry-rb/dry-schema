---
title: Basics
layout: gem-single
name: dry-schema
sections:
  - macros
  - type-specs
  - built-in-predicates
  - working-with-schemas
---

Here's a basic example where we validate the following things:

- The input _must have a key_ called `:email`
  - Provided the email key is present, its value _must be filled_
- The input _must have a key_ called `:age`
  - Provided the age key is present, its value _must be an integer_ and it _must be greater than 18_

This can be easily expressed through the DSL:

```ruby
require 'dry-schema'

schema = Dry::Schema.Params do
  required(:email).filled(:string)
  required(:age).filled(:integer, gt?: 18)
end

schema.call(email: 'jane@doe.org', age: 19)
# #<Dry::Schema::Result{:email=>"jane@doe.org", :age=>19} errors={}>

schema.call("email" => "", "age" => "19")
# #<Dry::Schema::Result{:email=>"", :age=>19} errors={:email=>["must be filled"]}>
```

When you apply this schema to an input, 3 things happen:

1. Input keys are coerced to symbols using schema's key map
2. Input values are coerced based on type specs
3. Input keys and values are validated using defined schema rules

### Learn more

- [Macros](/gems/dry-schema/basics/macros)
- [Type specs](/gems/dry-schema/basics/type-specs)
- [Built-in predicates](/gems/dry-schema/basics/built-in-predicates)
- [Working with schemas](/gems/dry-schema/basics/working-with-schemas)
