# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'open_api_parser/version'

Gem::Specification.new do |spec|
  spec.name          = 'open_api_parser'
  spec.version       = OpenApiParser::VERSION
  spec.authors       = ['Braintree']
  spec.email         = ['code@getbraintree.com']

  spec.summary       = 'A parser for Open API specifications'
  spec.description   = 'A parser for Open API specifications'
  spec.homepage      = 'https://github.com/braintree/open_api_parser'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.0'

  spec.add_dependency 'addressable', '~> 2.3'
  spec.add_dependency 'json-schema', '~> 2.8'

  spec.add_development_dependency 'bundler', '~> 2.1'
  spec.add_development_dependency 'pry', '~> 0.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '<= 0.76' # rubocop 0.86 has breaking change in cop names
end
