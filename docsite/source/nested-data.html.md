---
title: Nested data
layout: gem-single
name: dry-schema
---

`dry-schema` supports validation of nested data.

### Nested `Hash`

To define validation rules for a nested hash you can use the same DSL on a specific key:

```ruby
schema = Dry::Schema.Params do
  required(:address).hash do
    required(:city).filled(:string, min_size?: 3)
    required(:street).filled(:string)
    required(:country).hash do
      required(:name).filled(:string)
      required(:code).filled(:string)
    end
  end
end

errors = schema.call({}).errors

puts errors.to_h.inspect
# { :address => ["is missing"] }

errors = schema.call(address: { city: 'NYC' }).errors

puts errors.to_h.inspect
# {
#   :address => [
#     { :street => ["is missing"] },
#     { :country => ["is missing"] }
#   ]
# }
```

It is equivalent to call `value` macro with `:hash` predicate and a block:

```ruby
schema = Dry::Schema.Params do
  required(:address).value(:hash) do
    # ...
  end
end
```

### Nested Maybe `Hash`

If a nested hash could be `nil`, simply use `maybe` macro with a block:

```ruby
schema = Dry::Schema.Params do
  required(:address).maybe(:hash) do
    required(:city).filled(:string, min_size?: 3)
    required(:street).filled(:string)
    required(:country).hash do
      required(:name).filled(:string)
      required(:code).filled(:string)
    end
  end
end

schema.(address: nil).success? # true
```

### Nested `Array`

You can use the `array` macro for validating each element in an array:

```ruby
schema = Dry::Schema.Params do
  required(:phone_numbers).array(:str?)
end

errors = schema.call(phone_numbers: '').messages

puts errors.to_h.inspect
# { :phone_numbers => ["must be an array"] }

errors = schema.call(phone_numbers: ['123456789', 123456789]).messages

puts errors.to_h.inspect
# {
#   :phone_numbers => {
#     1 => ["must be a string"]
#   }
# }
```

You can use `array(:hash)` and `schema` to validate an array of hashes:

```ruby
schema = Dry::Schema.Params do
  required(:people).array(:hash) do
    required(:name).filled(:string)
    required(:age).filled(:integer, gteq?: 18)
  end
end

errors = schema.call(people: [{ name: 'Alice', age: 19 }, { name: 'Bob', age: 17 }]).errors

puts errors.to_h.inspect
# => {
#   :people=>{
#     1=>{
#       :age=>["must be greater than or equal to 18"]
#     }
#   }
# }
```

To add array predicates, use the full form:

```ruby
schema = Dry::Schema.Params do
  required(:people).value(:array, min_size?: 1).each do
    hash do
      required(:name).filled(:string)
      required(:age).filled(:integer, gteq?: 18)
    end
  end
end

errors = schema.call(people: []).errors

puts errors.to_h.inspect
# => {
#   :people=>["size cannot be less than 1"]
# }

```

Use `maybe(array[?])` to validate an array that could be `nil`:

```ruby
nested_schema = Dry::Schema.Params do
  required(:name).filled(:string)
end

schema = Dry::Schema.Params do
  required(:tags).maybe(array[nested_schema])
end

schema.call(tags: nil).success? # true
schema.call(tags: [{ name: 'Alice' }, { name: 'Bob' }]).success? # true
```

Or use `maybe(:array)` with a block:

```ruby
schema = Dry::Schema.Params do
  required(:tags).maybe(:array) do
    nil? | each(:hash) do
      required(:name).filled(:string)
    end
  end
end

schema.call(tags: nil).success? # true
schema.call(tags: [{ name: 'Alice' }, { name: 'Bob' }]).success? # true
```
