# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'omniauth/saml/multi_provider/version'

Gem::Specification.new do |spec|
  spec.name          = 'omniauth-multi-provider-saml'
  spec.version       = OmniAuth::SAML::MultiProvider::VERSION
  spec.authors       = ['Joel Turkel']
  spec.email         = ['jturkel@salsify.com']

  spec.summary       = 'An extension to omniauth-saml for handling multiple identity providers '
  spec.homepage      = 'https://github.com/salsify/omniauth-multi-provider-saml'
  spec.license       = 'MIT'

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
    spec.metadata['rubygems_mfa_required'] = 'true'
  else
    raise 'RubyGems 2.0 or newer is required to set allowed_push_host.'
  end

  spec.files         = ['README.md'] + Dir['lib/**/*.rb']
  spec.require_paths = ['lib']

  spec.add_dependency 'omniauth'
  spec.add_dependency 'omniauth-saml'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
end
