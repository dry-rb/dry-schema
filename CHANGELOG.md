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
