require 'spec_helper'

describe OmniAuth::SAML::MultiProvider::Handler do
  let(:path_prefix) { '/users/auth' }
  let(:provider_name) { 'saml2' }
  let(:identity_provider_id_regex) { /[[:alpha:]]+/ }
  let(:options_generator) do
    Proc.new do
      {}
    end
  end
  let(:strategy_options) { {} }
  let(:mock_strategy) { double(options: strategy_options) }

  let(:handler) do
    OmniAuth::SAML::MultiProvider::Handler.new(path_prefix: path_prefix, provider_name: provider_name,
                                               identity_provider_id_regex: identity_provider_id_regex,
                                               &options_generator)
  end

  let(:provider_options) { handler.provider_options }

  describe "#provider_options" do
    describe "path_prefix" do
      specify do
        expect(provider_options[:path_prefix]).to eq path_prefix
      end
    end

    describe "name" do
      specify do
        expect(provider_options[:name]).to eq provider_name
      end
    end

    describe "request_path" do
      let(:request_path_proc) { provider_options[:request_path] }

      it "returns true for request paths" do
        rack_env = create_rack_env(path: "#{path_prefix}/#{provider_name}/idp")
        expect(request_path_proc.call(rack_env)).to eq true
      end

      it "returns true for request paths ending in a slash" do
        rack_env = create_rack_env(path: "#{path_prefix}/#{provider_name}/idp/")
        expect(request_path_proc.call(rack_env)).to eq true
      end

      it "returns false for request paths with additional path segments" do
        rack_env = create_rack_env(path: "#{path_prefix}/#{provider_name}/idp/foo")
        expect(request_path_proc.call(rack_env)).to eq false
      end

      it "returns false for request paths that don't match the identity provider id regex" do
        rack_env = create_rack_env(path: "#{path_prefix}/foo123")
        expect(request_path_proc.call(rack_env)).to eq false
      end

      it "returns false for other omniauth providers" do
        rack_env = create_rack_env(path: "#{path_prefix}/foo/bar")
        expect(request_path_proc.call(rack_env)).to eq false
      end
    end

    describe "callback_path" do
      let(:callback_path_proc) { provider_options[:callback_path] }

      it "returns true for request paths" do
        rack_env = create_rack_env(path: "#{path_prefix}/#{provider_name}/idp/callback")
        expect(callback_path_proc.call(rack_env)).to eq true
      end

      it "returns true for request paths ending in a slash" do
        rack_env = create_rack_env(path: "#{path_prefix}/#{provider_name}/idp/callback/")
        expect(callback_path_proc.call(rack_env)).to eq true
      end

      it "returns false for request paths with additional path segments" do
        rack_env = create_rack_env(path: "#{path_prefix}/#{provider_name}/idp/callback/foo")
        expect(callback_path_proc.call(rack_env)).to eq false
      end

      it "returns false for request paths that don't match the identity provider id regex" do
        rack_env = create_rack_env(path: "#{path_prefix}/foo123/callback")
        expect(callback_path_proc.call(rack_env)).to eq false
      end

      it "returns false for other omniauth providers" do
        rack_env = create_rack_env(path: "#{path_prefix}/foo/bar/callback")
        expect(callback_path_proc.call(rack_env)).to eq false
      end
    end

    describe "#setup" do
      let(:identity_provider_id) { 'idp' }
      let(:rack_env) do
        create_rack_env(path: "#{path_prefix}/#{provider_name}/#{identity_provider_id}/callback")
      end

      let(:options_generator) do
        Proc.new do
          { foo: 'bar' }
        end
      end

      context "when the options generator proc returns a valid result" do
        before do
          provider_options[:setup].call(rack_env)
        end

        it "sets the strategy's request_path" do
          expect(strategy_options[:request_path]).to eq "#{path_prefix}/#{provider_name}/#{identity_provider_id}"
        end

        it "sets the strategy's callback_path" do
          expect(strategy_options[:callback_path]).to eq "#{path_prefix}/#{provider_name}/#{identity_provider_id}/callback"
        end

        it "adds options returned by the option generator proc" do
          expect(strategy_options[:foo]).to eq 'bar'
        end
      end

      context "when the options generator throws an exception" do
        let(:failure_result) { 'fail result' }
        let(:mock_strategy) { double(options: strategy_options, fail!: failure_result) }

        let(:options_generator) do
          Proc.new do
            raise 'identity provider not found'
          end
        end

        it "throws a warden symbol with the failure result" do
          expect do
            provider_options[:setup].call(rack_env)
          end.to throw_symbol(:warden, failure_result)
        end
      end
    end

    def create_rack_env(path:, strategy: mock_strategy)
      {
          'PATH_INFO' => path,
          'omniauth.strategy' => strategy
      }
    end
  end

end
