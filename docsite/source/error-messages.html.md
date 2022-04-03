---
title: Error messages
layout: gem-single
name: dry-schema
---

By default `dry-schema` comes with a set of pre-defined error messages for every built-in predicate. They are defined in [a yaml file](https://github.com/dry-rb/dry-schema/blob/main/config/errors.yml) which is shipped with the gem. This file is compatible with `I18n` format.

## Configuration

You can provide your own messages and configure your schemas to use it like that:

```ruby
schema = Dry::Schema.Params do
  config.messages.load_paths << '/path/to/my/errors.yml'
end
```

You can also provide a namespace per-schema that will be used by default:

```ruby
schema = Dry::Schema.Params do
  config.messages.namespace = :user
end
```

You can change the default top namespace using:

```ruby
schema = Dry::Schema.Params do
  config.messages.top_namespace = :validation_schema
end
```

## Lookup rules

```yaml
en:
  dry_schema:
    errors:
      size?:
        arg:
          default: "size must be %{num}"
          range: "size must be within %{left} - %{right}"

        value:
          string:
            arg:
              default: "length must be %{num}"
              range: "length must be within %{left} - %{right}"

      filled?: "must be filled"

      included_in?: "must be one of %{list}"
      excluded_from?: "must not be one of: %{list}"

      rules:
        email:
          filled?: "the email is missing"

        user:
          filled?: "name cannot be blank"

          rules:
            address:
              filled?: "You gotta tell us where you live"
```

Given the yaml file above, messages lookup works as follows:

```ruby
messages = Dry::Schema::Messages::YAML.load(%w(/path/to/our/errors.yml))

# matching arg type for size? predicate
messages[:size?, rule: :name, arg_type: Fixnum] # => "size must be %{num}"
messages[:size?, rule: :name, arg_type: Range] # => "size must be within %{left} - %{right}"

# matching val type for size? predicate
messages[:size?, rule: :name, val_type: String] # => "length must be %{num}"

# matching predicate
messages[:filled?, rule: :age] # => "must be filled"
messages[:filled?, rule: :address] # => "must be filled"

# matching predicate for a specific rule
messages[:filled?, rule: :email] # => "the email is missing"

# with namespaced messages
user_messages = messages.namespaced(:user)

user_messages[:filled?, rule: :age] # "cannot be blank"
user_messages[:filled?, rule: :address] # "You gotta tell us where you live"
```

By configuring `load_paths` and/or `namespace` in a schema, default messages are going to be automatically merged with your overrides and/or namespaced.

### I18n integration

If you are using `i18n` gem and load it before `dry-schema` then you'll be able to configure a schema to use `i18n` messages:

```ruby
require 'i18n'
require 'dry-schema'

schema = Dry::Schema.Params do
  config.messages.backend = :i18n

  required(:email).filled(:string)
end

# return default translations
schema.call(email: '').errors.to_h
{ :email => ["must be filled"] }

# return other translations (assuming you have it :))
puts schema.call(email: '').errors(locale: :pl).to_h
{ :email => ["musi być wypełniony"] }
```

Important: I18n must be initialized before using a schema, `dry-schema` does not try to do it for you, it only sets its default error translations automatically.

### Full messages

By default, messages do not include a rule's name, if you want it to be included simply use `:full` option:

```ruby
schema.call(email: '').errors(full: true).to_h
{ :email => ["email must be filled"] }
```

### Finding the right key

`dry-schema` has one error key for each kind of validation (Refer to [`errors.yml`](https://github.com/dry-rb/dry-schema/blob/main/config/errors.yml) for the full list). `key?` and `filled?` can usually be mistaken for each other, so pay attention to them:

- `key?`: a required parameter is missing in the `params` hash.
- `filled?`: a required parameter is in the `params` hash but has an empty value.
