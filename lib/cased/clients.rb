# frozen_string_literal: true

require 'cased/http/client'

module Cased
  class Clients
    def self.create(api_key:, url: nil)
      url ||= Cased.config.api_url

      Cased::HTTP::Client.new(url: url, api_key: api_key)
    end

    def organization
      @organization ||= self.class.create(api_key: ENV.fetch('CASED_ORGANIZATION_KEY'))
    end

    def publish
      @publish ||= self.class.create(url: Cased.config.publish_url, api_key: Cased.config.publish_key)
    end
  end
end
