# frozen_string_literal: true

require 'cased/query'

module Cased
  class Policy
    attr_reader :api_key
    attr_reader :client

    def initialize(api_key:)
      @api_key = api_key
      @client = Cased::Clients.create(api_key: @api_key)
    end

    def events(phrase: nil, variables: {})
      Query.new(@client, phrase: phrase, variables: variables)
    end

    def event(id)
      response = @client.get("events/#{id}")
      response.body
    end
  end
end
