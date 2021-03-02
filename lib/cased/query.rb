# frozen_string_literal: true

require 'cased/collection_response'
require 'forwardable'

module Cased
  class Query
    extend Forwardable

    # @param client [Cased::HTTP::Client] the HTTP client authorized to query an
    #   audit trail policy
    # @param phrase [String, nil] the phrase to search for audit trail events
    # @param variables [Hash] the query variables
    def initialize(client, phrase: nil, variables: {})
      raise ArgumentError, 'variables must be a Hash' unless variables.is_a?(Hash)

      @client = client
      @phrase = phrase
      @page = 1
      @limit = 25
      @variables = variables
    end

    # @param new_phrase [String] The audit trail policy search phrase.
    # @return [Cased::Query]
    def phrase(new_phrase)
      @phrase = new_phrase

      self
    end

    # @param new_limit [Integer] The number of audit trail events to return.
    # @return [Cased::Query]
    def limit(new_limit)
      @limit = [[new_limit, 100].min, 1].max

      self
    end

    # @param new_page [Integer] The page of audit trail events to request.
    # @return [Cased::Query]
    def page(new_page)
      @page = [1, new_page.to_i].max

      self
    end

    # If any of these methods are called we need the request to fulfil the response.
    def_delegators :response, \
      :results, \
      :total_count, \
      :total_pages, \
      :next_page_url?, \
      :next_page_url, \
      :next_page, \
      :next_page?, \
      :previous_page_url?, \
      :previous_page_url, \
      :previous_page, \
      :previous_page?, \
      :first_page_url?, \
      :first_page_url, \
      :first_page, \
      :first_page?, \
      :last_page_url?, \
      :last_page_url, \
      :last_page, \
      :last_page?, \
      :error, \
      :error?, \
      :success?

    def response
      return @response if defined?(@response)

      @response = begin
        resp = @client.get('events') do |req|
          req.params['phrase'] = @phrase unless @phrase.nil?
          req.params['per_page'] = @limit unless @limit.nil?
          req.params['page'] = @page unless @page.nil?
          req.params['variables'] = @variables unless @variables.nil?
        end

        CollectionResponse.new(response: resp)
      rescue Cased::HTTP::Error, Faraday::Error => e
        CollectionResponse.new(exception: e)
      end
    end
  end
end
