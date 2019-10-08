---
title: Processor steps
layout: gem-single
name: dry-schema
---

^WARNING
This feature is experimental. It should become stable in version 2.0.0.
^

Schemas process the input using 4 steps:

1. `key_coercer` - Prepare input hash using a key map
2. `filter_schema` - Apply pre-coercion filtering rules
   (optional step, used only when `filter` was used)
3. `value_coercer` - Apply value coercions based on type specifications
4. `rule_applier` - Apply rules

It is possible to add `before` or `after` callbacks to theses steps if you wish to customize processing. Let's say you want to remove all keys with `nil` values before coercion is applied:

```ruby
schema = Dry::Schema.Params do
  required(:name).value(:string)
  optional(:age).value(:integer)

  before(:value_coercer) do |result|
    result.to_h.compact
  end
end
```

Now when the schema is applied, it'll remove all keys with `nil` values before coercions and rules are applied:

```ruby
schema.(name: "Jane", age: nil)
# => #<Dry::Schema::Result{:name=>"jane"} errors={}>
```
