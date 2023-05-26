---
title: Custom predicates
layout: gem-single
name: dry-schema
---

If you want to define custom predicates, you can create a special module that includes default ones along with your custom functions:

```ruby
module MyPredicates
  include Dry::Logic::Predicates

  def self.future_date?(date)
    date > Date.today
  end
end
```

Then you can configure it as your default predicates module:

```ruby
Schema = Dry::Schema.Params do
  config.predicates = MyPredicates

  required(:release_date).value(:date, :future_date?)
end
```

Notice that you need to provide custom error messages for your own predicates.

## Learn more

- [Error messages](docs::error-messages)
