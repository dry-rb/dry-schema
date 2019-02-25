# 0.2.0 to-be-released

### Fixed

* Rule name translation works correctly with I18n (issue #52) (solnic)
* Rule name translation works correctly with namespaced messages (both I18n and plain YAML) (issue #57) (solnic)
* Error messages under namespaces are correctly resolved for overridden names (issue #53) (solnic)
* Namespaced error messages work correctly when schemas are reused within other schemas (issue #49) (solnic)
* Child schema can override inherited rules now (issue #66) (skryukov)
* Hints are correctly generated for disjunction that use type-check predicates (issue #24) (solnic)
* Hints are correctly generated for nested schemas (issue #26) (solnic)
* `filled` macro respects inferred type-check predicates and puts them in front (solnic)

### Changed

* [BREAKING] **Messages are now configured under `dry_schema` namespace by default** (issue #38) (solnic)
* [BREAKING] Hints are now an optional feature provided by `:hints` extension, to load it do `Dry::Schema.load_extensions(:hints)` (solnic)
* [BREAKING] Hints generation was improved in general, output of `Result#messages` and `Result#hints` changed in some cases (solnic)
* [BREAKING] Support for MRI < 2.4 was dropped (solnic)


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
