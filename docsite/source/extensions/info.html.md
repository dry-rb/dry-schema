---
title: Info
layout: gem-single
name: dry-schema
---

If you need to introspect your keys and types, you can enable `:info` extension which adds `#info` method to all schema types. This method returns a simple data structure that provides basic information about keys and types.

^WARN
The `info` data structure is not stable yet and may change before 2.0.0 depending on the user feedback.
^

```ruby
require 'dry/schema'

Dry::Schema.load_extensions(:info)

UserSchema = Dry::Schema.JSON do
  required(:email).filled(:string)
  optional(:age).filled(:integer)
  optional(:address).hash do
    required(:street).filled(:string)
    required(:zipcode).filled(:string)
    required(:city).filled(:string)
  end
end

UserSchema.info
# {
#   :keys=> {
#     :email=>{
#       :required=>true,
#       :type=>"string"
#     },
#     :age=>{
#       :required=>false,
#       :type=>"integer"
#      },
#     :address=>{
#       :type=>"hash",
#       :required=>false,
#       :keys=>{
#         :street=>{
#           :required=>true,
#           :type=>"string"
#         },
#         :zipcode=>{
#           :required=>true,
#           :type=>"string"
#         },
#         :city=>{
#           :required=>true,
#           :type=>"string"
#         }
#       }
#     }
#   }
# }
```
