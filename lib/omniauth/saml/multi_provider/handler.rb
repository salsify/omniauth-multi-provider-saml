require 'omniauth'
require 'omniauth-saml'

module OmniAuth
  module SAML
    module MultiProvider
      class Handler
        UUID_REGEX = /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/

        attr_reader :path_prefix, :provider_name

        def initialize(path_prefix: OmniAuth.config.path_prefix, provider_name: 'saml', &provider_options_generator)
          raise 'Missing provider options generator block' unless block_given?

          @path_prefix = path_prefix
          @provider_name = provider_name
          @provider_options_generator = provider_options_generator

          # Eagerly compute these since lazy evaluation will not be threadsafe
          @provider_path_prefix = "#{path_prefix}/#{provider_name}"
          @saml_path_regex = /^#{@provider_path_prefix}\/(?<identity_provider_id>#{UUID_REGEX})/
          @request_path_regex = /#{saml_path_regex}\/?$/
          @callback_path_regex = /#{saml_path_regex}\/callback\/?$/
        end

        def provider_options
          {
              path_prefix: path_prefix,
              name: provider_name,
              request_path: method(:request_path?),
              callback_path: method(:callback_path?),
              setup: method(:setup)
          }
        end

        private

        attr_reader :provider_path_prefix, :saml_path_regex, :request_path_regex, :callback_path_regex,
                    :provider_options_generator

        def setup(env)
          identity_provider_uuid = extract_identity_provider_id(env)
          if identity_provider_uuid
            options = env['omniauth.strategy'].options
            add_path_options(options, identity_provider_uuid)
            add_identity_provider_options(options, identity_provider_uuid)
          end
        end

        def add_path_options(options, identity_provider_uuid)
          options.merge!(
              request_path: "#{provider_path_prefix}/#{identity_provider_uuid}",
              callback_path: "#{provider_path_prefix}/#{identity_provider_uuid}/callback"
          )
        end

        def add_identity_provider_options(options, identity_provider_uuid)
          identity_provider_options = provider_options_generator.call(identity_provider_uuid) || {}
          options.merge!(identity_provider_options)
        rescue e
          raise OmniAuth::Strategies::SAML::ValidationError.new('Invalid identity provider id')
        end

        def request_path?(env)
          path = current_path(env)
          !!request_path_regex.match(path)
        end

        def callback_path?(env)
          path = current_path(env)
          !!callback_path_regex.match(path)
        end

        def current_path(env)
          env['PATH_INFO']
        end

        def extract_identity_provider_id(env)
          path = current_path(env)
          match = saml_path_regex.match(path)
          match ? match[:identity_provider_id] : nil
        end
      end
    end
  end
end
