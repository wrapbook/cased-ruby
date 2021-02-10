# frozen_string_literal: true

module Cased
  class Config
    # The amount of time in seconds to allow the HTTP client to open a
    # connection.
    #
    # @example
    #    CASED_HTTP_OPEN_TIMEOUT="5" rails server
    #
    # @example
    #    Cased.configure do |config|
    #      config.http_open_timeout = 5
    #    end
    attr_reader :http_open_timeout

    # The amount of time in seconds to allow the HTTP client to read a response
    # from the server before timing out.
    #
    # @example
    #    CASED_HTTP_READ_TIMEOUT="10" rails server
    #
    # @example
    #    Cased.configure do |config|
    #      config.http_read_timeout = 10
    #    end
    attr_reader :http_read_timeout

    # The Cased HTTP API URL. Defaults to https://api.cased.com
    #
    # @example
    #    CASED_API_URL="https://api.cased.com" rails server
    #
    # @example
    #    Cased.configure do |config|
    #      config.api_url = "https://api.cased.com"
    #    end
    attr_accessor :api_url

    # @example
    #    GUARD_APPLICATION_KEY="guard_application_1ntKX0P4vUbKoc0lMWGiSbrBHcH" rails server
    #
    # @example
    #    Cased.configure do |config|
    #      config.guard_application_key = "guard_application_1ntKX0P4vUbKoc0lMWGiSbrBHcH"
    #    end
    attr_reader :guard_application_key

    # The URL to publish audit events to. Defaults to https://publish.cased.com
    #
    # @example
    #    CASED_PUBLISH_URL="https://publish.cased.com" rails server
    #
    # @example
    #    Cased.configure do |config|
    #      config.publish_url = "https://publish.cased.com"
    #    end
    attr_accessor :publish_url

    # Publish keys are used to publish to an audit trail.
    #
    # A publish key is associated with a single audit trail and is required if
    # you intend to publish events to Cased in your application.
    #
    # @example
    #    CASED_PUBLISH_KEY="publish_test_5dSfh6xZAuL2Esn3Z2XSM6ReMS21" rails server
    #
    # @example
    #    Cased.configure do |config|
    #      config.publish_key = "publish_test_5dSfh6xZAuL2Esn3Z2XSM6ReMS21"
    #    end
    attr_accessor :publish_key

    #
    # @example
    #    CASED_ORGANIZATION_POLICY_KEY="policy_live_1dQpY2mRu3pTCcNGB7a6ewx4WFp" \
    #    CASED_SECURITY_POLICY_KEY="policy_live_1dQpY9Erf3cKUrooz0BQKmCD4Oc" \
    #    CASED_USER_POLICY_KEY="policy_live_1dSHQRbtjj17LanuAgpHd3QKtOO" \
    #      rails server
    #
    # @example
    #    Cased.configure do |config|
    #      config.policy_keys = {
    #        organization: "policy_live_1dQpY2mRu3pTCcNGB7a6ewx4WFp",
    #        security: "policy_live_1dQpY9Erf3cKUrooz0BQKmCD4Oc",
    #        user: "policy_live_1dSHQRbtjj17LanuAgpHd3QKtOO",
    #      }
    #    end
    attr_reader :policy_keys

    # Policy keys are used to query for events from audit trails.
    #
    # @example
    #    CASED_POLICY_KEY="policy_live_1dQpY1fUFHzENWhTVMvjCilAKp9" rails server
    #
    # @example
    #    Cased.configure do |config|
    #      config.raise_on_errors = !Rails.env.production?
    #    end
    attr_reader :raise_on_errors

    # Configure whether or not Cased will attempt to publish any events.
    #
    # If the CASED_SILENCE environment variable is not nil Cased will
    # not publish events.
    #
    # @example
    #    CASED_SILENCE="1" rails server
    #
    # @example
    #    Cased.configure do |config|
    #      config.silence = Rails.env.test?
    #    end
    #
    # @example
    #   Cased.silence do
    #     User.create!
    #   end
    attr_writer :silence

    def initialize
      @http_read_timeout = ENV.fetch('CASED_HTTP_READ_TIMEOUT', 10).to_i
      @http_open_timeout = ENV.fetch('CASED_HTTP_OPEN_TIMEOUT', 5).to_i
      @raise_on_errors = !ENV['CASED_RAISE_ON_ERRORS'].nil?
      @api_url = ENV.fetch('CASED_API_URL', 'https://api.cased.com')
      @publish_url = ENV.fetch('CASED_PUBLISH_URL', 'https://publish.cased.com')
      @guard_application_key = ENV['GUARD_APPLICATION_KEY']
      @publish_key = ENV['CASED_PUBLISH_KEY']
      @silence = !ENV['CASED_SILENCE'].nil?
      @policy_keys = Hash.new do |hash, key|
        normalized_key = key.to_sym
        if normalized_key == :default
          hash[normalized_key] = ENV['CASED_POLICY_KEY']
        else
          env_policy_name = key.to_s.tr(' ', '_').tr('-', '_').upcase
          api_key = ENV["CASED_#{env_policy_name}_POLICY_KEY"]

          hash[normalized_key] = api_key if api_key
        end
      end
    end

    # Policy keys are used to query for events from audit trails.
    #
    # @param [Symbol] policy name
    #
    # @example
    #    CASED_POLICY_KEY="policy_live_1dQpY1fUFHzENWhTVMvjCilAKp9" rails server
    #
    # @example
    #    Cased.configure do |config|
    #      config.policy_key = "policy_live_1dQpY1fUFHzENWhTVMvjCilAKp9"
    #    end
    def policy_key(policy = :default)
      policy_keys[policy.to_sym]
    end

    def policy_key=(api_key)
      policy_keys[:default] = api_key
    end

    def raise_on_errors=(new_val)
      @raise_on_errors = !!new_val
    end

    def http_read_timeout=(new_val)
      @http_read_timeout = new_val.to_i
    end

    def http_open_timeout=(new_val)
      @http_open_timeout = new_val.to_i
    end

    def raise_on_errors?
      @raise_on_errors
    end

    def silence?
      @silence || !ENV['CASED_SILENCE'].nil?
    end
  end
end
