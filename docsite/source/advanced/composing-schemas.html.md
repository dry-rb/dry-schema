---
title: Composing schemas
layout: gem-single
name: dry-schema
---

^WARNING
This feature is experimental until dry-schema reaches 2.0.0
^

You can compose schemas using the following standard logic operators:

* `s1 & s2` - both schemas must pass
* `s1 | s2` - both or one of the schemas must pass
* `s1 > s2` - if `s1` passes then `s2` must be pass too, otherwise the entire statement passes

^INFO
Currently `^` (`xor`) is not supported because it's not yet clear how to generate errors messages in this case
^

### Using `&`

When you compose schemas using `&`, the right side will be applied only when left side passed first:

```ruby
Role = Dry::Schema.JSON do
  required(:id).filled(:string)
end

Expirable = Dry::Schema.JSON do
  required(:expires_on).value(:date)
end

User = Dry::Schema.JSON do
  required(:name).filled(:string)
  required(:role).hash(Role & Expirable)
end

puts User.(name: "Jane", role: { id: "admin", expires_on: "2020-05-01" }).errors.to_h.inspect
# {}

puts User.(name: "Jane", role: { id: "", expires_on: "2020-05-01" }).errors.to_h.inspect
# {role: {id: ["must be filled"]}}

puts User.(name: "Jane", role: { id: "admin", expires_on: "oops" }).errors.to_h.inspect
# {role: {expires_on: ["must be a date"]}}
```

### Using `|`

When you use `|`, both schemas will be applied and the error messages will be nested under special `:or` key:

```ruby
RoleID = Dry::Schema.JSON do
  required(:id).filled(:string)
end

RoleTitle = Dry::Schema.JSON do
  required(:title).filled(:string)
end

User = Dry::Schema.JSON do
  required(:name).filled(:string)
  required(:role).hash(RoleID | RoleTitle)
end

puts User.(name: "Jane", role: {id: "admin"}).errors.to_h.inspect
# {}

puts User.(name: "Jane", role: {title: "Admin"}).errors.to_h.inspect

puts User.(name: "Jane", role: { id: ""}).errors.to_h.inspect
# {:role=>{:or=>[{:id=>["must be filled"]}, {:title=>["is missing"]}]}}

puts User.(name: "Jane", role: { title: ""}).errors.to_h.inspect
# {:role=>{:or=>[{:id=>["is missing"]}, {:title=>["must be filled"]}]}}
```

### Using `>`

When you compose schemas using `>`, the right side will be applied only if the left side passed:

```ruby
RoleID = Dry::Schema.JSON do
  required(:id).filled(:string)
end

RoleTitle = Dry::Schema.JSON do
  required(:title).filled(:string)
end

User = Dry::Schema.JSON do
  required(:name).filled(:string)
  required(:role).hash(RoleID > RoleTitle)
end

puts User.(name: "Jane", role: {id: "admin", title: "Admin"}).errors.to_h.inspect
# {}

puts User.(name: "Jane", role: { id: ""}).errors.to_h.inspect
# {}

puts User.(name: "Jane", role: {title: "Admin"}).errors.to_h.inspect
# {}

puts User.(name: "Jane", role: { id: "admin", title: ""}).errors.to_h.inspect
# {:role=>{:title=>["must be filled"]}}
```
