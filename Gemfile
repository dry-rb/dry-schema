# frozen_string_literal: true

source "https://rubygems.org"

eval_gemfile "Gemfile.devtools"

gemspec

gem "dry-configurable", github: "dry-rb/dry-configurable", branch: "main"
gem "dry-logic", github: "dry-rb/dry-logic", branch: "main"
gem "dry-types", github: "dry-rb/dry-types", branch: "main"
gem "dry-core", github: "dry-rb/dry-core", branch: "main"

group :test do
  gem "dry-monads", require: false, github: "dry-rb/dry-monads", branch: "main"
  gem "dry-struct", require: false, github: "dry-rb/dry-struct", branch: "main"
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
