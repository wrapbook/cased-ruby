# frozen_string_literal: true

module Cased
  class ResponseTest < Cased::Test
    def test_successful_response
      conn = Faraday.new do |builder|
        builder.adapter :test do |stub|
          stub.get('/events') { |_env| [200, {}, '[]'] }
        end
      end
      response = Cased::Response.new(response: conn.get('/events'))

      assert_predicate response, :success?
      refute_predicate response, :error?
      assert_nil response.exception
      assert_equal '[]', response.body
    end

    def test_error_response
      exception = StandardError.new
      response = Cased::Response.new(exception: exception)

      refute_predicate response, :success?
      assert_predicate response, :error?
      assert_equal exception, response.exception
      assert_nil response.body
    end
  end
end
