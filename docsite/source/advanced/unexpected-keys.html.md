---
title: Unexpected keys
layout: gem-single
name: dry-schema
---

You can enable special key validation which will provide error messages about unexpected keys in an input. This is useful if you want to be very strict about what your system allows.

In order to use this type of validation, you need to enable it via `config`:

```ruby
# Enable it globally
Dry::Schema.config.validate_keys = true


# or per schema
Dry::Schema.Params do
  config.validate_keys = true

  # ...
end
```

Here's a simple usage example:

```ruby
require 'dry/schema'

UserSchema = Dry::Schema.Params do
  config.validate_keys = true

  required(:name).filled(:string)

  required(:address).hash do
    required(:city).filled(:string)
    required(:zipcode).filled(:string)
  end

  required(:roles).array(:hash) do
    required(:name).filled(:string)
  end
end

input = {
  foo: 'unexpected',
  name: 'Jane',
  address: { bar: 'unexpected', city: 'NYC', zipcode: '1234' },
  roles: [{ name: 'admin' }, { name: 'editor', foo: 'unexpected' }]
}

UserSchema.(input).errors.to_h
# {
#  :foo=>["is not allowed"],
#  :address=>{:bar=>["is not allowed"]},
#  :roles=>{1=>{:foo=>["is not allowed"]}}
# }
```
