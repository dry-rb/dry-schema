# frozen_string_literal: true

source "https://rubygems.org"

eval_gemfile "Gemfile.devtools"

gemspec

gem "dry-configurable", github: "dry-rb/dry-configurable", branch: "master" if ENV["DRY_CONFIGURABLE_FROM_MASTER"].eql?("true") # rubocop:disable Layout/LineLength
gem "dry-logic", github: "dry-rb/dry-logic", branch: "master" if ENV["DRY_LOGIC_FROM_MASTER"].eql?("true") # rubocop:disable Layout/LineLength
gem "dry-types", github: "dry-rb/dry-types", branch: "master"

group :test do
  gem "dry-monads", require: false, github: "dry-rb/dry-monads"
  gem "dry-struct", require: false, github: "dry-rb/dry-struct"
  gem "i18n", "1.8.2", require: false
  gem "transproc"
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
