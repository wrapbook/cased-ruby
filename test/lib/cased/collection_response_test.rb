# frozen_string_literal: true

module Cased
  class CollectionResponseTest < Cased::Test
    def test_successful_response
      links = [
        '</api/events?page=1&per_page=25>; rel="first"',
        '</api/events?page=100&per_page=25>; rel="last"',
        '</api/events?page=3&per_page=25>; rel="next"',
        '</api/events?page=1&per_page=25>; rel="prev"',
      ]
      body = {
        total_pages: 10,
        total_count: 100,
        results: [],
      }.to_json

      conn = Faraday.new do |builder|
        builder.adapter :test do |stub|
          stub.get('/events?page=2') do |_env|
            headers = {
              'Link' => links.join(', '),
            }

            [200, headers, body]
          end
        end
      end
      response = Cased::CollectionResponse.new(response: conn.get('/events?page=2'))

      assert_predicate response, :success?
      assert_predicate response, :next_page_url?
      assert_predicate response, :next_page?
      assert_predicate response, :previous_page_url?
      assert_predicate response, :previous_page?
      assert_predicate response, :first_page_url?
      assert_predicate response, :first_page?
      assert_predicate response, :last_page_url?
      assert_predicate response, :last_page?
      assert_equal '/api/events?page=1&per_page=25', response.first_page_url
      assert_equal '/api/events?page=100&per_page=25', response.last_page_url
      assert_equal '/api/events?page=1&per_page=25', response.previous_page_url
      assert_equal '/api/events?page=3&per_page=25', response.next_page_url
      assert_equal 1, response.first_page
      assert_equal 100, response.last_page
      assert_equal 1, response.previous_page
      assert_equal 3, response.next_page
      refute_predicate response, :error?
      assert_nil response.exception
      assert_equal body, response.body
    end

    def test_error_response
      body = {
        error: 'type',
        message: 'Error message',
      }.to_json

      conn = Faraday.new do |builder|
        builder.adapter :test do |stub|
          stub.get('/events?page=2') do |_env|
            [500, {}, body]
          end
        end
      end
      response = Cased::CollectionResponse.new(response: conn.get('/events?page=2'))

      assert_predicate response, :error?
      refute_predicate response, :success?
      refute_predicate response, :next_page_url?
      refute_predicate response, :next_page?
      refute_predicate response, :previous_page_url?
      refute_predicate response, :previous_page?
      refute_predicate response, :first_page_url?
      refute_predicate response, :first_page?
      refute_predicate response, :last_page_url?
      refute_predicate response, :last_page?
      assert_nil response.first_page_url
      assert_nil response.first_page
      assert_nil response.last_page_url
      assert_nil response.last_page
      assert_nil response.previous_page_url
      assert_nil response.previous_page
      assert_nil response.next_page_url
      assert_nil response.next_page
      assert_nil response.exception
      assert_equal body, response.body
    end

    def test_next_page
      conn = Faraday.new do |builder|
        builder.adapter :test do |stub|
          stub.get('/events') do |_env|
            headers = {
              'Link' => '</api/events?page=3&per_page=25>; rel="next"',
            }

            [200, headers, '']
          end
        end
      end
      response = Cased::CollectionResponse.new(response: conn.get('/events'))

      assert_predicate response, :next_page_url?
      assert_predicate response, :next_page?
      assert_equal '/api/events?page=3&per_page=25', response.next_page_url
      assert_equal 3, response.next_page
    end

    def test_previous_page
      conn = Faraday.new do |builder|
        builder.adapter :test do |stub|
          stub.get('/events') do |_env|
            headers = {
              'Link' => '</api/events?page=1&per_page=25>; rel="prev"',
            }

            [200, headers, '']
          end
        end
      end
      response = Cased::CollectionResponse.new(response: conn.get('/events'))

      assert_predicate response, :previous_page_url?
      assert_predicate response, :previous_page?
      assert_equal '/api/events?page=1&per_page=25', response.previous_page_url
      assert_equal 1, response.previous_page
    end

    def test_last_page
      conn = Faraday.new do |builder|
        builder.adapter :test do |stub|
          stub.get('/events') do |_env|
            headers = {
              'Link' => '</api/events?page=100&per_page=25>; rel="last"',
            }

            [200, headers, '']
          end
        end
      end
      response = Cased::CollectionResponse.new(response: conn.get('/events'))

      assert_predicate response, :last_page_url?
      assert_predicate response, :last_page?
      assert_equal '/api/events?page=100&per_page=25', response.last_page_url
      assert_equal 100, response.last_page
    end

    def test_first_page
      conn = Faraday.new do |builder|
        builder.adapter :test do |stub|
          stub.get('/events') do |_env|
            headers = {
              'Link' => '</api/events?page=1&per_page=25>; rel="first"',
            }

            [200, headers, '']
          end
        end
      end
      response = Cased::CollectionResponse.new(response: conn.get('/events'))

      assert_predicate response, :first_page_url?
      assert_predicate response, :first_page?
      assert_equal '/api/events?page=1&per_page=25', response.first_page_url
      assert_equal 1, response.first_page
    end

    def test_results
      conn = Faraday.new do |builder|
        builder.response :json
        builder.adapter :test do |stub|
          stub.get('/events') do |_env|
            headers = {
              'Content-Type' => 'application/json',
            }

            [200, headers, '{ "results": [true] }']
          end
        end
      end
      response = Cased::CollectionResponse.new(response: conn.get('/events'))

      assert_equal [true], response.results
    end

    def test_total_pages
      conn = Faraday.new do |builder|
        builder.response :json
        builder.adapter :test do |stub|
          stub.get('/events') do |_env|
            headers = {
              'Content-Type' => 'application/json',
            }

            [200, headers, '{ "total_pages": 10 }']
          end
        end
      end
      response = Cased::CollectionResponse.new(response: conn.get('/events'))

      assert_equal 10, response.total_pages
    end

    def test_total_count
      conn = Faraday.new do |builder|
        builder.response :json
        builder.adapter :test do |stub|
          stub.get('/events') do |_env|
            headers = {
              'Content-Type' => 'application/json',
            }

            [200, headers, '{ "total_count": 100 }']
          end
        end
      end
      response = Cased::CollectionResponse.new(response: conn.get('/events'))

      assert_equal 100, response.total_count
    end
  end
end
