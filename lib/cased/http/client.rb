# frozen_string_literal: true

require 'cased/http/error'
require 'faraday'
require 'faraday_middleware'

module Cased
  module HTTP
    class Client
      def initialize(url:, api_key:, raise_on_errors: false)
        @raise_on_errors = raise_on_errors
        @client = ::Faraday.new(url: url) do |conn|
          conn.headers[:user_agent] = "cased-ruby/v#{Cased::VERSION}"
          conn.headers[:content_type] = 'application/json'
          conn.headers[:accept] = 'application/json'
          conn.headers[:authorization] = "Bearer #{api_key}"

          conn.request :json
          conn.response :json, content_type: /\bjson$/

          conn.options.timeout = Cased.config.http_read_timeout
          conn.options.open_timeout = Cased.config.http_open_timeout
        end
      end

      # Requests with bodies

      def put(url = nil, body = nil, headers = nil, &block)
        request(:put, url, body, headers, &block)
      end

      def post(url = nil, body = nil, headers = nil, &block)
        request(:post, url, body, headers, &block)
      end

      def patch(url = nil, body = nil, headers = nil, &block)
        request(:patch, url, body, headers, &block)
      end

      # Requests without bodies

      def get(url = nil, params = nil, headers = nil)
        request(:get, url, nil, headers) do |req|
          req.params.update(params) if params
          yield req if block_given?
        end
      end

      def head(url = nil, params = nil, headers = nil)
        request(:head, url, nil, headers) do |req|
          req.params.update(params) if params
          yield req if block_given?
        end
      end

      def delete(url = nil, params = nil, headers = nil)
        request(:delete, url, nil, headers) do |req|
          req.params.update(params) if params
          yield req if block_given?
        end
      end

      def trace(url = nil, params = nil, headers = nil)
        request(:trace, url, nil, headers) do |req|
          req.params.update(params) if params
          yield req if block_given?
        end
      end

      private

      def request(method, url = nil, params_or_body = nil, headers = nil, &block)
        response = @client.send(method, url, params_or_body, headers, &block)

        if !response.success? && raise_on_errors?
          klass = Cased::HTTP::Error.class_from_response(response)
          raise klass.from_response(response)
        else
          response
        end
      end

      def raise_on_errors?
        @raise_on_errors
      end
    end
  end
end
