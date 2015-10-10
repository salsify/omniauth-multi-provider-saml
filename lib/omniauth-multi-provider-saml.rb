require 'omniauth/saml/multi_provider/handler'
require 'omniauth/saml/multi_provider/version'

module OmniAuth
  module SAML
    module MultiProvider
      def self.register(builder, path_prefix: OmniAuth.config.path_prefix,
          identity_provider_id_regex: /\w+/, **options, &dynamic_options_generator)

        handler = OmniAuth::SAML::MultiProvider::Handler.new(path_prefix: path_prefix,
                                                             identity_provider_id_regex: identity_provider_id_regex,
                                                             &dynamic_options_generator)
        static_options = options.merge(path_prefix: path_prefix)
        builder.provider(:saml, static_options.merge(handler.provider_options))
      end
    end
  end
end
