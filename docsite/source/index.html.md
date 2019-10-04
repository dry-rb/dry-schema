---
title: Introduction
description: Schema coercion & validation
layout: gem-single
type: gem
name: dry-schema
sections:
  - basics
  - optional-keys-and-values
  - nested-data
  - reusing-schemas
  - params
  - json
  - error-messages
  - advanced
  - extensions
---

`dry-schema` is a validation library for **data structures**. It ships with a set of many built-in predicates and powerful macros that allow you to define even complex validation logic with very concise syntax.

Main focus of this library is on:

- Data **structure** validation
- Value **types** validation

^INFO
`dry-schema` is also used as the schema engine in [dry-validation](/gems/dry-validation)
^

### Unique features

There are a few features of `dry-schema` that make it unique:

* [Structural validation](/gems/dry-schema/optional-keys-and-values) where key presence can be verified separately from values. This removes ambiguity related to "presence" validation where you don't know if value is indeed `nil` or if a key is missing in the input hash
* [Pre-coercion validation using filtering rules](/gems/dry-schema/advanced/filtering)
* Explicit coercion logic - rather than implementing complex generic coercions, `dry-schema` uses coercion types from `dry-types` which are faster and more strict than generic coercions
* Support for [validating array elements](/gems/dry-schema/basics/macros#array) with convenient access to error messages
* Powerful introspection - you have access to [key maps](/gems/dry-schema/advanced/key-maps) and detailed [Rule AST](/gems/dry-schema/advanced/rule-ast)
* Performance - multiple times faster than validations based on `ActiveModel` and `strong parameters`
* Configurable, localized error messages with or *without* `I18n` gem

### When to use?

Always and everywhere. This is a general-purpose data validation library that can be used for many things and **it's multiple times faster** than `ActiveRecord`/`ActiveModel::Validations` _and_ `strong-parameters`.

Possible use-cases include validation of:

- Form params
- "GET" params
- JSON documents
- YAML documents
- Application configuration (ie stored in ENV)
- Replacement for `strong-parameters`
- etc.

### Quick start

```ruby
require 'dry/schema'

UserSchema = Dry::Schema.Params do
  required(:name).filled(:string)
  required(:email).filled(:string)

  required(:age).maybe(:integer)

  required(:address).hash do
    required(:street).filled(:string)
    required(:city).filled(:string)
    required(:zipcode).filled(:string)
  end
end

UserSchema.(
  name: 'Jane',
  email: 'jane@doe.org',
  address: { street: 'Street 1', city: 'NYC', zipcode: '1234' }
).inspect

# #<Dry::Schema::Result{:name=>"Jane", :email=>"jane@doe.org", :address=>{:street=>"Street 1", :city=>"NYC", :zipcode=>"1234"}} errors={:age=>["age is missing"]}>
```
