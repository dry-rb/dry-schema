---
title: Filtering
layout: gem-single
name: dry-schema
---

One of the unique features of `dry-schema` is the ability to define rules that are applied **before coercion**. This means you can ensure that **the input** has the right format for the coercion to work, or maybe you just want to restrict certain values entering your system.

Here's a common example - your system supports only one specific date format, and you want to validate that the input value has this format before trying to coerce it into a date object. In order to do that, you can use `filter` macro, which works just like `value`, but its predicates are applied before value coercion:

```ruby
schema = Dry::Schema.Params do
  required(:email).filled
  required(:birthday).filter(format?: /\d{4}-\d{2}-\d{2}/).value(:date)
end

schema.call('email' => 'jane@doe.org', 'birthday' => '1981-1-1')
#<Dry::Schema::Result{:email=>"jane@doe.org", :birthday=>"1981-1-1"} errors={:birthday=>["is in invalid format"]}>

schema.call('email' => 'jane@doe.org', 'birthday' => '1981-01-01')
#<Dry::Schema::Result{:email=>"jane@doe.org", :birthday=>#<Date: 1981-01-01 ((2444606j,0s,0n),+0s,2299161j)>} errors={}>
```
