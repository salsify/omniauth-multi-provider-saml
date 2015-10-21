# Omniauth Multiple Provider SAML

This is a simple extension to [omniauth-saml](https://github.com/PracticallyGreen/omniauth-saml) for supporting multiple identity providers based on a URL path segment e.g. dispatching requests to `/auth/saml/foo` to identity provider "foo" and `/app/saml/bar` to identity provider "bar".

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'omniauth-multi-provider-saml'
```

And then execute:

    $ bundle
    
Or install it yourself as:

    $ gem install omniauth-multi-provider-saml

## Setup

**I would highly recommend first getting [omniauth-saml](https://github.com/PracticallyGreen/omniauth-saml) setup to work with a single identity provider before attempting to use this gem.** 

The setup process consists of the following steps:

1. Add an omniauth-saml monkey patch for omniauth-saml PR [#56](https://github.com/PracticallyGreen/omniauth-saml/pull/56).
1. Configure your routes to handle SAML routes for multiple identity providers
1. Configure omniauth-saml to choose the appropriate identity provider

### Monkey Patch omniauth-saml

This step will only be necessary until omniauth-saml PR [#56](https://github.com/PracticallyGreen/omniauth-saml/pull/56) merges. Place the following in an initializer:

```ruby
require 'omniauth-saml'

OmniAuth::Strategies::SAML.class_eval do

  private

  def initialize_copy(orig)
    super
    @options = @options.deep_dup
  end
end
```

### Configure SAML Routes

Add something like the following to your routes assuming you're using Rails (your actual URL structure may vary):

```ruby
MyApplication::Application.routes.draw do
  match '/auth/saml/:identity_provider_id/callback',
        via: [:get, :post],
        to: 'omniauth_callbacks#saml',
        as: 'user_omniauth_callback'

  match '/auth/saml/:identity_provider_id',
        via: [:get, :post],
        to: 'omniauth_callbacks#passthru',
        as: 'user_omniauth_authorize'
end
```

### Configure omniauth-saml to use multiple identity providers

The basic configuration looks something like this:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  OmniAuth::SAML::MultiProvider.register(self, issuer: 'Salsify') do |identity_provider_id, rack_env|
    # Customize this code to return the appropriate SAML options for the given identity provider
    # See omniauth-saml for details on the supported options
    identity_provider = IdentityProvider.find_by!(uuid: identity_provider_id)
    identity_provider.options
  end
end
```
The `OmniAuth::SAML::MultiProvider.register` method takes a hash of static omniauth-saml options and a block to generate any request specific options. It also takes the following options:
* `identity_provider_id_regex` - The regex for a valid identity provider id. Defaults to `/\w+/`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/salsify/omniauth-multi-provider-saml.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

