---
title: Reusing schemas
layout: gem-single
name: dry-schema
---

You can easily reuse existing schemas using nested-schema syntax:

```ruby
AddressSchema = Dry::Schema.Params do
  required(:street).filled(:string)
  required(:city).filled(:string)
  required(:zipcode).filled(:string)
end

UserSchema = Dry::Schema.Params do
  required(:email).filled(:string)
  required(:name).filled(:string)
  required(:address).hash(AddressSchema)
end

UserSchema.(
  email: 'jane@doe',
  name: 'Jane',
  address: { street: nil, city: 'NYC', zipcode: '123' }
).errors.to_h

# {:address=>{:street=>["must be filled"]}}
```
