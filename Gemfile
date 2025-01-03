# frozen_string_literal: true

source "https://rubygems.org"

eval_gemfile "Gemfile.devtools"

gemspec

gem "dry-configurable", github: "dry-rb/dry-configurable", branch: "main"
gem "dry-logic", github: "dry-rb/dry-logic", branch: "main"
gem "dry-types", github: "dry-rb/dry-types", branch: "main"
gem "dry-core", github: "dry-rb/dry-core", branch: "main"

group :test do
  gem "dry-monads"
  gem "dry-struct"
  gem "i18n", "1.8.2", require: false
  gem "json-schema"
  gem "transproc"
end

group :tools do
  gem "pry-byebug"
  gem "redcarpet", platform: :mri
end

group :benchmarks do
  gem "actionpack"
  gem "activemodel"
  gem "benchmark-ips"
  # gem "hotch", platform: :mri
  gem "virtus"
end
