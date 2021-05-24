require_relative "lib/api_service_c8r/version"

Gem::Specification.new do |spec|
  spec.name        = "api_service_c8r"
  spec.email       = "o.o.krol96@gmail.com"
  spec.authors     = ["Alexey Melnikov", "Oleg Krol"]
  spec.version     = ApiServiceC8r::VERSION

  spec.summary     = "Simple gem for move controller's action logic to service"
  spec.description = spec.summary
  spec.files       = ["lib/api_service_c8r.rb"]
  spec.homepage    = "https://github.com/datacrafts-io/api_service_c8r"
  spec.license     = "MIT"

  spec.required_ruby_version = Gem::Requirement.new(">= 2.6.5")

  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.require_paths = %w[lib]

  spec.add_development_dependency "bundler", ">= 1.16"
  spec.add_development_dependency "rubocop"
end
