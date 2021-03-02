# frozen_string_literal: true

require 'cased/http/client'

module Cased
  class Clients
    def self.create(api_key:, url: nil, raise_on_errors: false)
      url ||= Cased.config.api_url

      Cased::HTTP::Client.new(url: url, api_key: api_key, raise_on_errors: raise_on_errors)
    end

    def organization
      @organization ||= self.class.create(api_key: ENV.fetch('CASED_ORGANIZATION_KEY'))
    end

    def publish
      @publish ||= self.class.create(url: Cased.config.publish_url, api_key: Cased.config.publish_key, raise_on_errors: true)
    end

    def cli
      @cli ||= self.class.create(api_key: Cased.config.guard_application_key)
    end
  end
end
