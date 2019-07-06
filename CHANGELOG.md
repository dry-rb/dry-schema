# 1.3.0 2019-07-06

### Added

- Automatic predicate inferring for constrained types! (@flash-gordon)

  ```ruby
  Types::Name = Types::String.constrained(min_size: 1)

  schema = Dry::Schema.define do
    required(:name).value(Types::Name)
  end

  schema.(name: '').errors.to_h # => { name: ["size cannot be less than 1"] }
  ```

- Support for redefining re-used schemas (issue #43) (@skryukov)

### Fixed

- Type container is passed down to nested schemas (@flash-gordon)

[Compare v1.2.0...v1.3.0](https://github.com/dry-rb/dry-schema/compare/v1.2.0...v1.3.0)

# v1.2.0 2019-06-13

### Added

- Ability to configure your own type container (@Morozzzko)

  ```ruby
  types = Dry::Schema::TypeContainer.new
  types.register(
    'params.trimmed_string',
    Types::String.constructor(&:strip).constructor(&:downcase)
  )

  Dry::Schema.Params do
    config.types = types

    require(:name).value(:trimmed_string)
  end
  ```

### Fixed

- `filled` macro no longer generates incorrect messages for arrays (issue #151) (@solnic)
- `filled` macro works correctly with constructor types (@solnic)
- `filled` works correctly with nested schemas (#149) (@solnic + @timriley)
- Custom array constructors are no longer discredited by `array` macro (@solnic)
- `BigDecimal` type is correctly handled by predicate inference (@solnic)
- Works with latest `dry-logic` which provides the new `respond_to?` predicate (#153) (@flash-gordon)

### Changed

- Fixes related to `filled` restored pre-1.1.0 behavior of `:hints` which are again included (@solnic)
- `filled` no longer uses filter rules to handle empty strings in `Params` (@solnic)

[Compare v1.1.0...v1.2.0](https://github.com/dry-rb/dry-schema/compare/v1.1.0...v1.2.0)

# v1.1.0 2019-05-30

### Added

- `config.messages.default_locale` for setting...default locale (surprise, surprise) (solnic)
- `Config` exposes `predicates` setting too (solnic)

### Fixed

- `filled` macro behavior results in `must be filled` error messages when appropriate - see PR #141 for more information (issue #134) (solnic)
- Filter rules no longer cause keys to be added to input (issue #142) (solnic)
- Filter rules work now with inheritance (solnic)
- Inherited type schemas used by coercion are now properly configured as `lax` type (solnic)
- `Config` is now finalized before instantiating schemas and properly dupped when its inherited (flash-gordon + solnic)
- `Config#eql?` works as expected (solnic)
- Predicates are properly inferred from array with a member type spec, ie `array[:integer]` results in `array? + each(:integer?)` (issue #140) (solnic)

[Compare v1.0.3...v1.1.0](https://github.com/dry-rb/dry-schema/compare/v1.0.3...v1.1.0)

# v1.0.3 2019-05-21

### Fixed

- `Object#hash` is no longer used to calculate cache keys due to a potential risk of having hash collisions (solnic)
- Predicate arguments are used again for template cache keys (solnic)
- `I18n` messages backend no longer evaluates templates twice (solnic)

[Compare v1.0.2...v1.0.3](https://github.com/dry-rb/dry-schema/compare/v1.0.2...v1.0.3)

# v1.0.2 2019-05-12

### Fixed

- Caching message templates uses restricted set of known keys to calculate cache keys (issue #132) (solnic)

[Compare v1.0.1...v1.0.2](https://github.com/dry-rb/dry-schema/compare/v1.0.1...v1.0.2)

# 1.0.1 2019-05-08

### Fixed

- Applying `key?` predicate no longer causes recursive calls to `Result#errors` (issue #130) (solnic)

[Compare v1.0.0...v1.0.1](https://github.com/dry-rb/dry-schema/compare/v1.0.0...v1.0.1)

# 1.0.0 2019-05-03

### Changed

- [BREAKING] `Result#to_hash` was removed (solnic)

### Fixed

- Setting `:any` as the type spec no longer crashes (solnic)
- `Result#error?` handles paths to array elements correctly (solnic)

[Compare v0.6.0...v1.0.0](https://github.com/dry-rb/dry-schema/compare/v0.6.0...v1.0.0)

# 0.6.0 2019-04-24

### Changed

- Dependency on `dry-types` was bumped to `~> 1.0` (solnic)
- Dependency on `dry-logic` was bumped to `~> 1.0` (solnic)
- Dependency on `dry-initializer` was bumped to `~> 3.0` (solnic)

[Compare v0.5.1...v0.6.0](https://github.com/dry-rb/dry-schema/compare/v0.5.1...v0.6.0)

# 0.5.1 2019-04-17

### Fixed

- Key map no longer crashes on unexpected input (issue #118) (solnic)

[Compare v0.5.0...v0.5.1](https://github.com/dry-rb/dry-schema/compare/v0.5.0...v0.5.1)

# 0.5.0 2019-04-04

### Added

- Support for arbitrary meta-data in messages, ie:

  ```yaml
  en:
    dry_schema:
      errors:
        filled?:
          text: "cannot be blank"
          code: 123
  ```

  Now your error hash will include `{ foo: [{ text: 'cannot be blank', code: 123 }] }` (solnic + flash-gordon)

- Support for type specs in `array` macro, ie `required(:tags).array(:integer)` (solnic)
- Support for type specs in `each` macro, ie `required(:tags).each(:integer)` (solnic)
- Shortcut for defining an array with hash as its member, ie:

  ```ruby
  Dry::Schema.Params do
    required(:tags).array(:hash) do
      required(:name).filled(:string)
    end
  end
  ```

### Fixed

- Inferring predicates doesn't crash when `Any` type is used (flash-gordon)
- Inferring type specs when type is already set works correctly (solnic)

### Changed

- [BREAKING] `:monads` extension wraps entire result objects in `Success` or `Failure` (flash-gordon)
- When `:hints` are disabled, result AST will not include hint nodes (solnic)

[Compare v0.4.0...v0.5.0](https://github.com/dry-rb/dry-schema/compare/v0.4.0...v0.5.0)

# 0.4.0 2019-03-26

### Added

- Schemas are now compatible with procs via `#to_proc` (issue #53) (solnic)
- Support for configuring `top_namespace` for localized messages (solnic)
- Support for configuring more than one load path for localized messages (solnic)
- Support for inferring predicates from arbitrary types (issue #101) (solnic)

### Fixed

- Handling of messages for `optional` keys without value rules works correctly (issue #87) (solnic)
- Message structure for `optional` keys with an array of hashes no longer duplicates keys (issue #89) (solnic)
- Inferring `:date_time?` predicate works correctly with `DateTime` types (issue #97) (solnic)

### Changed

- [BREAKING] Updated to work with `dry-types 0.15.0` (flash-gordon)
- [BREAKING] `Result#{errors,messages,hints}` returns `MessageSet` object now which is an enumerable coercible to a hash (solnic)
- [BREAKING] `Messages` backend classes no longer use global configuration (solnic)
- [BREAKING] Passing a non-symbol key name in the DSL will raise `ArgumentError` (issue #29) (solnic)
- [BREAKING] Configuration for message backends is now nested under `messages` key with following settings:
  - `messages.backend` - previously `messages`
  - `messages.load_paths` - previously `messages_path`
  - `messages.namespace` - previously `namespace`
  - `messages.top_namespace` - **new setting** see above
- [BREAKING] `Messages::I18n` uses `I18.store_translations` instead of messing with `I18n.load_path` (solnic)
- Schemas (`Params` and `JSON`) have nicer inspect (solnic)

[Compare v0.3.0...v0.4.0](https://github.com/dry-rb/dry-schema/compare/v0.3.0...v0.4.0)

# 0.3.0 2018-03-04

### Fixed

- Configuration is properly inherited from a parent schema (skryukov)
- `Result#error?` returns `true` when a preceding key has errors (solnic)
- Predicate inferrer no longer chokes on sum, constructor and enum types (solnic)
- Predicate inferrer infers `:bool?` from boolean types (solnic)
- Block-based definitions using `array` works correctly (solnic)
- Using a disjunction with `array` and `hash` produces correct errors when element validation for array failed (solnic)

### Changed

- Required ruby version was removed from gemspec for people who are stuck on MRI 2.3.x (solnic)

[Compare v0.2.0...v0.3.0](https://github.com/dry-rb/dry-schema/compare/v0.2.0...v0.3.0)

# 0.2.0 2019-02-26

### Added

- New `hash` macro which prepends `hash?` type-check and allows nested schema definition (solnic)
- New `array` macro which works like `each` but prepends `array?` type-check (solnic)

### Fixed

- Rule name translation works correctly with I18n (issue #52) (solnic)
- Rule name translation works correctly with namespaced messages (both I18n and plain YAML) (issue #57) (solnic)
- Error messages under namespaces are correctly resolved for overridden names (issue #53) (solnic)
- Namespaced error messages work correctly when schemas are reused within other schemas (issue #49) (solnic)
- Child schema can override inherited rules now (issue #66) (skryukov)
- Hints are correctly generated for disjunction that use type-check predicates (issue #24) (solnic)
- Hints are correctly generated for nested schemas (issue #26) (solnic)
- `filled` macro respects inferred type-check predicates and puts them in front (solnic)
- Value coercion works correctly with re-usable nested schemas (issue #25) (solnic)

### Changed

- [BREAKING] **Messages are now configured under `dry_schema` namespace by default** (issue #38) (solnic)
- [BREAKING] Hints are now an optional feature provided by `:hints` extension, to load it do `Dry::Schema.load_extensions(:hints)` (solnic)
- [BREAKING] Hints generation was improved in general, output of `Result#messages` and `Result#hints` changed in some cases (solnic)
- [BREAKING] `schema` macro no longer prepends `hash?` check, for this behavior use the new `hash` macro (see #31) (solnic)
- [BREAKING] Support for MRI < 2.4 was dropped (solnic)

[Compare v0.1.1...v0.2.0](https://github.com/dry-rb/dry-schema/compare/v0.1.1...v0.2.0)

# 0.1.1 2019-02-17

### Added

- `Result#error?` supports checking nested errors too ie`result.error?('user.address')` (solnic)

### Fixed

- Fix issues with templates and invalid tokens (issue #27) (solnic)
- Fix Ruby warnings (flash-gordon)

### Internal

- Key and value coercers are now equalizable (flash-gordon)

[Compare v0.1.0...v0.1.1](https://github.com/dry-rb/dry-schema/compare/v0.1.0...v0.1.1)

# 0.1.0 2019-01-30

Initial release.
