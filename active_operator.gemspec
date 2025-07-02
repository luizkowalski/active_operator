# frozen_string_literal: true

require_relative "lib/active_operator/version"

Gem::Specification.new do |spec|
  spec.name          = "active_operator"
  spec.version       = ActiveOperator::VERSION
  spec.authors       = ["Jeremy Smith"]
  spec.email         = ["jeremy@jeremysmith.co"]

  spec.summary       = "A Rails pattern for calling external APIs, then storing and processing their responses"
  spec.homepage      = "https://github.com/jeremysmithco/active_operator"
  spec.license       = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir[
    "lib/**/*",
    "CHANGELOG.md",
    "README.md",
    "LICENSE",
  ]

  spec.require_paths = ["lib"]

  spec.add_dependency "activejob", ">= 7.2"
  spec.add_dependency "activerecord", ">= 7.2"
end
