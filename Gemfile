# frozen_string_literal: true

source "https://rubygems.org"

eval_gemfile "Gemfile.devtools"

gemspec

group :test do
  gem "dry-monads"
  gem "dry-struct"
  gem "i18n", require: false
  gem "json-schema"
  gem "ostruct"
  gem "transproc"
end

group :tools do
  gem "pry-byebug"
  gem "readline"
  gem "redcarpet", platform: :mri
end

group :benchmarks do
  gem "actionpack"
  gem "activemodel"
  gem "benchmark-ips"
  # gem "hotch", platform: :mri
  gem "virtus"
end
