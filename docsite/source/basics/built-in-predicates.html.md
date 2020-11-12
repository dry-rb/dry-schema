---
title: Built-in predicates
layout: gem-single
name: dry-schema
---

The DSL supports many built-in predicates that can be used to verify validity of the input. If the predicates do not meet your requirements, you probably want to look at [dry-validation](/gems/dry-validation) which offers a more advanced way of defining validations.

### `nil?`

Checks that a key's value is nil.

```ruby
describe 'nil?' do
  let(:schema) do
    Dry::Schema.Params do
      required(:sample).value(:nil?)
    end
  end

  let(:input) { {sample: nil} }

  it 'as regular ruby' do
    assert input[:sample].nil?
  end

  it 'with dry-schema' do
    assert schema.call(input).success?
  end
end
```

### `eql?`

Checks that a key's value is equal to the given value.

```ruby
describe 'eql?' do
  let(:schema) do
    Dry::Schema.Params do
      required(:sample).value(eql?: 1234)
    end
  end

  let(:input) { {sample: 1234} }

  it 'as regular ruby' do
    assert input[:sample] == 1234
  end

  it 'with dry-schema' do
     assert schema.call(input).success?
  end
end
```

## Types

### `type?`

Checks that a key's class is equal to the given value.

```ruby
describe 'type?' do
  let(:schema) do
    Dry::Schema.Params do
      required(:sample).value(type?: Integer)
    end
  end

  let(:input) { {sample: 1234} }

  it 'as regular ruby' do
    assert input[:sample].class == Integer
  end

  it 'with dry-schema' do
    assert schema.call(input).success?
  end
end
```

Shorthand for common Ruby types:

- `str?` equivalent to `type?(String)`
- `int?` equivalent to `type?(Integer)`
- `float?` equivalent to `type?(Float)`
- `decimal?` equivalent to `type?(BigDecimal)`
- `bool?` equivalent to `type?(Boolean)`
- `date?` equivalent to `type?(Date)`
- `time?` equivalent to `type?(Time)`
- `date_time?` equivalent to `type?(DateTime)`
- `array?` equivalent to `type?(Array)`
- `hash?` equivalent to `type?(Hash)`

## Number, String, Collection

### `empty?`

Checks that either the array, string, or hash is empty.

```ruby
describe 'empty?' do
  let(:schema) do
    Dry::Schema.Params do
      required(:sample).value(:empty?)
    end
  end

  it 'with regular ruby' do
    assert {sample: ""}[:sample].empty?
    assert {sample: []}[:sample].empty?
    assert {sample: {}}[:sample].empty?
  end

  it 'with dry-schema' do
    assert schema.call(sample: "").success?
    assert schema.call(sample: []).success?
    assert schema.call(sample: {}).success?
  end
end
```

### `filled?`

Checks that either the value is non-nil and, in the case of a String, Hash, or Array, non-empty.

```ruby
describe 'filled?' do
  let(:schema) do
    Dry::Schema.Params do
      required(:sample).value(:filled?)
    end
  end

  it 'with regular ruby' do
    assert !{sample: "1"}[:sample].empty?
    assert !{sample: [2]}[:sample].empty?
    assert !{sample: {k: 3}}[:sample].empty?
  end

  it 'with dry-schema' do
    assert schema.call(sample: "1").success?
    assert schema.call(sample: [2]).success?
    assert schema.call(sample: {k: 3}).success?
  end
end
```

### `gt?`

Checks that the value is greater than the given value.

```ruby
describe 'gt?' do
  let(:schema) do
    Dry::Schema.Params do
      required(:sample).value(gt?: 0)
    end
  end

  it 'with regular ruby' do
    assert 1 > 0
  end

  it 'with dry-schema' do
    assert schema.call(sample: 1).success?
  end
end
```

### `gteq?`

Checks that the value is greater than or equal to the given value.

```ruby
describe 'gteq?' do
  let(:schema) do
    Dry::Schema.Params do
      required(:sample).value(gteq?: 1)
    end
  end

  it 'with regular ruby' do
    assert 1 >= 1
  end

  it 'with dry-schema' do
    assert schema.call(sample: 1).success?
  end
end
```

### `lt?`

Checks that the value is less than the given value.

```ruby
describe 'lt?' do
  let(:schema) do
    Dry::Schema.Params do
      required(:sample).value(lt?: 1)
    end
  end

  it 'with regular ruby' do
    assert 0 < 1
  end

  it 'with dry-schema' do
    assert schema.call(sample: 0).success?
  end
end
```

### `lteq?`

Checks that the value is less than or equal to the given value.

```ruby
describe 'lteq?' do
  let(:schema) do
    Dry::Schema.Params do
      required(:sample).value(lteq?: 1)
    end
  end

  it 'with regular ruby' do
    assert 1 <= 1
  end

  it 'with dry-schema' do
    assert schema.call(sample: 1).success?
  end
end
```

### `max_size?`

Check that an array's size (or a string's length) is less than or equal to the given value.

```ruby
describe 'max_size?' do
  let(:schema) do
    Dry::Schema.Params do
      required(:sample).value(max_size?: 3)
    end
  end

  it 'with regular ruby' do
    assert [1, 2, 3].size <= 3
    assert 'foo'.size <= 3
  end

  it 'with dry-schema' do
    assert schema.call(sample: [1, 2, 3]).success?
    assert schema.call(sample: 'foo').success?
  end
end
```

### `min_size?`

Checks that an array's size (or a string's length) is greater than or equal to the given value.

```ruby
describe 'min_size?' do
  let(:schema) do
    Dry::Schema.Params do
      required(:sample).value(min_size?: 3)
    end
  end

  it 'with regular ruby' do
    assert [1, 2, 3].size >= 3
    assert 'foo'.size >= 3
  end

  it 'with dry-schema' do
    assert schema.call(sample: [1, 2, 3]).success?
    assert schema.call(sample: 'foo').success?
  end
end
```

### `size?(int)`

Checks that an array's size (or a string's length) is equal to the given value.

```ruby
describe 'size?' do
  let(:schema) do
    Dry::Schema.Params do
      required(:sample).value(size?: 3)
    end
  end

  it 'with regular ruby' do
    assert [1, 2, 3].size == 3
    assert 'foo'.size == 3
  end

  it 'with dry-schema' do
    assert schema.call(sample: [1, 2, 3]).success?
    assert schema.call(sample: 'foo').success?
  end
end
```

### `size?(range)`

Checks that an array's size (or a string's length) is within a range of values.

```ruby
describe 'size?' do
  let(:schema) do
    Dry::Schema.Params do
      required(:sample).value(size?: 0..3)
    end
  end

  it 'with regular ruby' do
    assert (0..3).include?([1, 2, 3].size)
    assert (0..3).include?('foo'.size)
  end

  it 'with dry-schema' do
    assert schema.call(sample: [1, 2, 3]).success?
    assert schema.call(sample: 'foo').success?
  end
end
```

### `max_bytesize?`

String's bytesize is less than or equal to the given value.

```ruby
describe 'max_bytesize?' do
  let(:schema) do
    Dry::Schema.Params do
      required(:sample).value(max_bytesize?: 3)
    end
  end

  it 'with regular ruby' do
    assert 'こ'.byte <= 3
  end

  it 'with dry-schema' do
    assert schema.call(sample: 'こ').success?
  end
end
```

### `min_bytesize?`

String's bytesize is greater than or equal to the given value.

```ruby
describe 'min_binsize?' do
  let(:schema) do
    Dry::Schema.Params do
      required(:sample).value(min_bytesize?: 3)
    end
  end

  it 'with regular ruby' do
    assert 'こ'.byte >= 3
  end

  it 'with dry-schema' do
    assert schema.call(sample: 'こ').success?
  end
end
```

### `bytesize?(int)`

Checks that an array's size (or a string's length) is equal to the given value.

```ruby
describe 'bytesize?' do
  let(:schema) do
    Dry::Schema.Params do
      required(:sample).value(bytesize?: 3)
    end
  end

  it 'with regular ruby' do
    assert 'こ'.byte == 3
  end

  it 'with dry-schema' do
    assert schema.call(sample: 'こ').success?
  end
end
```

### `bytesize?(range)`

Checks that an array's size (or a string's length) is within a range of values.

```ruby
describe 'bytesize?' do
  let(:schema) do
    Dry::Schema.Params do
      required(:sample).value(bytesize?: 0..3)
    end
  end

  it 'with regular ruby' do
    assert (0..3).include?('こ'.size)
  end

  it 'with dry-schema' do
    assert schema.call(sample: 'こ').success?
  end
end
```

### `format?`

Checks that a string matches a given regular expression.

```ruby
describe 'format?' do
  let(:schema) do
    Dry::Schema.Params do
      required(:sample).value(format?: /^a/)
    end
  end

  it 'with regular ruby' do
    assert /^a/ =~ "aa"
  end

  it 'with dry-schema' do
     assert schema.call(sample: "aa").success?
  end
end
```

### `included_in?`

Checks that a value is included in a given array.

```ruby
describe 'included_in?' do
  let(:schema) do
    Dry::Schema.Params do
      required(:sample).value(included_in?: [1,3,5])
    end
  end

  it 'with regular ruby' do
    assert [1,3,5].include?(3)
  end

  it 'with dry-schema' do
    assert schema.call(sample: 3).success?
  end
end
```

### `excluded_from?`

Checks that a value is excluded from a given array.

```ruby
describe 'excluded_from?' do
  let(:schema) do
    Dry::Schema.Params do
      required(:sample).value(excluded_from?: [1,3,5])
    end
  end

  it 'with regular ruby' do
    assert ![1,3,5].include?(2)
  end

  it 'with dry-schema' do
    assert schema.call(sample: 2).success?
  end
end
```
