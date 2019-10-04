---
title: Key maps
layout: gem-single
name: dry-schema
---

When you define a schema, you get access to the key map which holds information about specified keys. Internally, `dry-schema` uses key maps to:

* Rebuild the original input hash by rejecting unknown keys
* (optional) coerce keys from strings to symbols

### Accessing key map

To access schema's key map use `Schema#key_map` method:

```ruby
schema = Dry::Schema.Params do
  required(:email).filled(:string)
  optional(:age).filled(:integer, gt?: 18)
end

schema.key_map
# => #<Dry::Schema::KeyMap["email", "age"]>

schema.key_map.write("email" => "jane@doe.org", "age" => 21, "something_unexpected" => "oops")
# => {:email=>"jane@doe.org", :age=>21}
```

### KeyMap is an enumerable

You can use `Enumerable` API when working with key maps:

``` ruby
schema.key_map.each { |key| puts key.inspect }
# #<Dry::Schema::Key name="email" coercer=#<Proc:0x00007feb288ff848(&:to_sym)>>
# #<Dry::Schema::Key name="age" coercer=#<Proc:0x00007feb288ff848(&:to_sym)>>

schema.key_map.detect { |key| key.name.eql?("email") }
# => #<Dry::Schema::Key name="email" coercer=#<Proc:0x00007feb288ff848(&:to_sym)>>
```

### Learn more

- [`KeyMap` API documentation](https://www.rubydoc.info/gems/dry-schema/Dry/Schema/KeyMap)
