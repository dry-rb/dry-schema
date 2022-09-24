# frozen_string_literal: true

source "https://rubygems.org"

eval_gemfile "Gemfile.devtools"

gemspec

# if ENV["DRY_CONFIGURABLE_FROM_MAIN"].eql?("true")
#   gem "dry-configurable", github: "dry-rb/dry-configurable", branch: "main"
# end
gem "dry-configurable", github: "dry-rb/dry-configurable", branch: "write-settings-in-configure-only"

if ENV["DRY_LOGIC_FROM_MAIN"].eql?("true")
  gem "dry-logic", github: "dry-rb/dry-logic", branch: "main"
end

group :test do
  gem "dry-monads", require: false
  gem "dry-struct", require: false
  gem "i18n", "1.8.2", require: false
  gem "transproc"
  gem "json-schema"
end

group :tools do
  gem "pry"
  gem "pry-byebug", platform: :mri
  gem "redcarpet", platform: :mri
end

group :benchmarks do
  gem "actionpack", "~> 5.0"
  gem "activemodel", "~> 5.0"
  gem "benchmark-ips"
  gem "hotch", platform: :mri
  gem "virtus"
end
