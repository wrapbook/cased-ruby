# frozen_string_literal: true

require 'test_helper'

module Cased
  module HTTP
    class ClientTest < Cased::Test
      def test_post_request
        stub_request(:post, 'https://publish.cased.com/')
          .with(
            headers: {
              'Accept' => 'application/json',
              'Authorization' => 'Bearer 12345',
              'Content-Type' => 'application/json',
            },
          )
          .to_return(status: 200)

        http = Cased::HTTP::Client.new(url: 'https://publish.cased.com/', api_key: '12345')
        http.post
      end

      def test_post_request_with_path_params_and_headers
        stub_request(:post, 'https://publish.cased.com/events?hello=true')
          .with(
            body: 'hi',
            headers: {
              'Accept' => 'application/json',
              'Authorization' => 'Bearer 12345',
              'Content-Type' => 'application/xml',
            },
          )
          .to_return(status: 200)

        http = Cased::HTTP::Client.new(url: 'https://publish.cased.com/', api_key: '12345')
        http.post('events', 'hi', content_type: 'application/xml') do |req|
          req.params['hello'] = true
        end
      end

      def test_put_request_with_path_params_and_headers
        stub_request(:put, 'https://publish.cased.com/events?hello=true')
          .with(
            body: 'hi',
            headers: {
              'Accept' => 'application/json',
              'Authorization' => 'Bearer 12345',
              'Content-Type' => 'application/xml',
            },
          )
          .to_return(status: 200)

        http = Cased::HTTP::Client.new(url: 'https://publish.cased.com/', api_key: '12345')
        http.put('events', 'hi', content_type: 'application/xml') do |req|
          req.params['hello'] = true
        end
      end

      def test_patch_request_with_path_params_and_headers
        stub_request(:patch, 'https://publish.cased.com/events?hello=true')
          .with(
            body: 'hi',
            headers: {
              'Accept' => 'application/json',
              'Authorization' => 'Bearer 12345',
              'Content-Type' => 'application/xml',
            },
          )
          .to_return(status: 200)

        http = Cased::HTTP::Client.new(url: 'https://publish.cased.com/', api_key: '12345')
        http.patch('events', 'hi', content_type: 'application/xml') do |req|
          req.params['hello'] = true
        end
      end

      def test_get_request_with_path_params_and_headers
        stub_request(:get, 'https://publish.cased.com/events?hello=true')
          .with(
            headers: {
              'Accept' => 'application/json',
              'Authorization' => 'Bearer 12345',
              'Content-Type' => 'application/xml',
            },
          )
          .to_return(status: 200)

        http = Cased::HTTP::Client.new(url: 'https://publish.cased.com/', api_key: '12345')
        http.get('events', nil, content_type: 'application/xml') do |req|
          req.params['hello'] = true
        end
      end

      def test_head_request_with_path_params_and_headers
        stub_request(:head, 'https://publish.cased.com/events?hello=true')
          .with(
            headers: {
              'Accept' => 'application/json',
              'Authorization' => 'Bearer 12345',
              'Content-Type' => 'application/xml',
            },
          )
          .to_return(status: 200)

        http = Cased::HTTP::Client.new(url: 'https://publish.cased.com/', api_key: '12345')
        http.head('events', nil, content_type: 'application/xml') do |req|
          req.params['hello'] = true
        end
      end

      def test_delete_request_with_path_params_and_headers
        stub_request(:delete, 'https://publish.cased.com/events?hello=true')
          .with(
            headers: {
              'Accept' => 'application/json',
              'Authorization' => 'Bearer 12345',
              'Content-Type' => 'application/xml',
            },
          )
          .to_return(status: 200)

        http = Cased::HTTP::Client.new(url: 'https://publish.cased.com/', api_key: '12345')
        http.delete('events', nil, content_type: 'application/xml') do |req|
          req.params['hello'] = true
        end
      end

      def test_trace_request_with_path_params_and_headers
        stub_request(:trace, 'https://publish.cased.com/events?hello=true')
          .with(
            headers: {
              'Accept' => 'application/json',
              'Authorization' => 'Bearer 12345',
              'Content-Type' => 'application/xml',
            },
          )
          .to_return(status: 200)

        http = Cased::HTTP::Client.new(url: 'https://publish.cased.com/', api_key: '12345')
        http.trace('events', nil, content_type: 'application/xml') do |req|
          req.params['hello'] = true
        end
      end

      def test_requests_include_useragent
        stub_request(:post, 'https://publish.cased.com/')
          .with(
            headers: {
              'User-Agent' => "cased-ruby/v#{Cased::VERSION}",
            },
          )
          .to_return(status: 200)

        http = Cased::HTTP::Client.new(url: 'https://publish.cased.com/', api_key: '12345')
        http.post
      end

      def test_exception_exposes_status_code_and_message
        stub_request(:post, 'https://publish.cased.com/')
          .to_return(status: 300, body: 'Error message')

        http = Cased::HTTP::Client.new(url: 'https://publish.cased.com/', api_key: '12345')
        exception = assert_raises(Cased::HTTP::Error::RedirectionError) do
          http.post
        end

        assert_equal 300, exception.code
        assert_equal 'Error message', exception.message
      end

      def test_raises_generic_redirection_error_if_not_in_errors_table
        stub_request(:post, 'https://publish.cased.com/')
          .to_return(status: 300)

        http = Cased::HTTP::Client.new(url: 'https://publish.cased.com/', api_key: '12345')
        assert_raises(Cased::HTTP::Error::RedirectionError) do
          http.post
        end
      end

      def test_raises_http_error_with_invalid_code
        stub_request(:post, 'https://publish.cased.com/')
          .to_return(status: 1)

        http = Cased::HTTP::Client.new(url: 'https://publish.cased.com/', api_key: '12345')
        assert_raises(Cased::HTTP::Error) do
          http.post
        end
      end

      def test_raises_generic_client_error_if_not_in_errors_table
        stub_request(:post, 'https://publish.cased.com/')
          .to_return(status: 499)

        http = Cased::HTTP::Client.new(url: 'https://publish.cased.com/', api_key: '12345')
        assert_raises(Cased::HTTP::Error::ClientError) do
          http.post
        end
      end

      def test_raises_generic_server_error_if_not_in_errors_table
        stub_request(:post, 'https://publish.cased.com/')
          .to_return(status: 505)

        http = Cased::HTTP::Client.new(url: 'https://publish.cased.com/', api_key: '12345')
        assert_raises(Cased::HTTP::Error::ServerError) do
          http.post
        end
      end

      def test_raises_bad_request
        stub_request(:post, 'https://publish.cased.com/')
          .to_return(status: 400)

        http = Cased::HTTP::Client.new(url: 'https://publish.cased.com/', api_key: '12345')
        assert_raises(Cased::HTTP::Error::BadRequest) do
          http.post
        end
      end

      def test_raises_unauthorized
        stub_request(:post, 'https://publish.cased.com/')
          .to_return(status: 401)

        http = Cased::HTTP::Client.new(url: 'https://publish.cased.com/', api_key: '12345')
        assert_raises(Cased::HTTP::Error::Unauthorized) do
          http.post
        end
      end

      def test_raises_forbidden
        stub_request(:post, 'https://publish.cased.com/')
          .to_return(status: 403)

        http = Cased::HTTP::Client.new(url: 'https://publish.cased.com/', api_key: '12345')
        assert_raises(Cased::HTTP::Error::Forbidden) do
          http.post
        end
      end

      def test_raises_not_found
        stub_request(:post, 'https://publish.cased.com/')
          .to_return(status: 404)

        http = Cased::HTTP::Client.new(url: 'https://publish.cased.com/', api_key: '12345')
        assert_raises(Cased::HTTP::Error::NotFound) do
          http.post
        end
      end

      def test_raises_not_acceptable
        stub_request(:post, 'https://publish.cased.com/')
          .to_return(status: 406)

        http = Cased::HTTP::Client.new(url: 'https://publish.cased.com/', api_key: '12345')
        assert_raises(Cased::HTTP::Error::NotAcceptable) do
          http.post
        end
      end

      def test_raises_request_timeout
        stub_request(:post, 'https://publish.cased.com/')
          .to_return(status: 408)

        http = Cased::HTTP::Client.new(url: 'https://publish.cased.com/', api_key: '12345')
        assert_raises(Cased::HTTP::Error::RequestTimeout) do
          http.post
        end
      end

      def test_raises_unprocessable_entity
        stub_request(:post, 'https://publish.cased.com/')
          .to_return(status: 422)

        http = Cased::HTTP::Client.new(url: 'https://publish.cased.com/', api_key: '12345')
        assert_raises(Cased::HTTP::Error::UnprocessableEntity) do
          http.post
        end
      end

      def test_raises_too_many_requests
        stub_request(:post, 'https://publish.cased.com/')
          .to_return(status: 429)

        http = Cased::HTTP::Client.new(url: 'https://publish.cased.com/', api_key: '12345')
        assert_raises(Cased::HTTP::Error::TooManyRequests) do
          http.post
        end
      end

      def test_raises_internal_server_error
        stub_request(:post, 'https://publish.cased.com/')
          .to_return(status: 500)

        http = Cased::HTTP::Client.new(url: 'https://publish.cased.com/', api_key: '12345')
        assert_raises(Cased::HTTP::Error::InternalServerError) do
          http.post
        end
      end

      def test_raises_bad_gateway
        stub_request(:post, 'https://publish.cased.com/')
          .to_return(status: 502)

        http = Cased::HTTP::Client.new(url: 'https://publish.cased.com/', api_key: '12345')
        assert_raises(Cased::HTTP::Error::BadGateway) do
          http.post
        end
      end

      def test_raises_service_unavailable
        stub_request(:post, 'https://publish.cased.com/')
          .to_return(status: 503)

        http = Cased::HTTP::Client.new(url: 'https://publish.cased.com/', api_key: '12345')
        assert_raises(Cased::HTTP::Error::ServiceUnavailable) do
          http.post
        end
      end

      def test_raises_gateway_timeout
        stub_request(:post, 'https://publish.cased.com/')
          .to_return(status: 504)

        http = Cased::HTTP::Client.new(url: 'https://publish.cased.com/', api_key: '12345')
        assert_raises(Cased::HTTP::Error::GatewayTimeout) do
          http.post
        end
      end
    end
  end
end
