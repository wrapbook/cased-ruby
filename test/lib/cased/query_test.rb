# frozen_string_literal: true

module Cased
  class QueryTest < Cased::Test
    def test_query_phrase_from_initializer
      ENV['CASED_ORGANIZATION_KEY'] = 'test'

      client = Cased.clients.organization
      query = Cased::Query.new(client, phrase: 'action:user.login')

      stub_request(:get, 'https://api.cased.com/events?page=1&per_page=25&phrase=action:user.login')
        .to_return(status: 200)

      assert_predicate query, :success?
    end

    def test_query_variables_from_initializer
      ENV['CASED_ORGANIZATION_KEY'] = 'test'

      client = Cased.clients.organization
      query = Cased::Query.new(client, variables: {
        action: 'user.login',
      })

      stub_request(:get, 'https://api.cased.com/events?page=1&per_page=25&variables%5Baction%5D=user.login')
        .to_return(status: 200)

      assert_predicate query, :success?
    end

    def test_query_with_empty_variables_doesnt_include_them_in_request
      ENV['CASED_ORGANIZATION_KEY'] = 'test'

      client = Cased.clients.organization
      query = Cased::Query.new(client, variables: {})

      stub_request(:get, 'https://api.cased.com/events?page=1&per_page=25')
        .to_return(status: 200)

      assert_predicate query, :success?
    end

    def test_raises_argument_error_if_variables_is_not_a_hash
      ENV['CASED_ORGANIZATION_KEY'] = 'test'

      client = Cased.clients.organization

      exception = assert_raises(ArgumentError) do
        Cased::Query.new(client, variables: 'action')
      end

      assert_equal 'variables must be a Hash', exception.message
    end

    def test_querying_expired_audit_trail_policy
      ENV['CASED_ORGANIZATION_KEY'] = 'test'

      client = Cased.clients.organization
      query = Cased::Query.new(client)

      body = <<~'BODY'
        {
          "error": "EXPIRED_AUDIT_TRAIL_POLICY",
          "message": "The policy-with-variable audit trail policy is no longer accessible."
        }
      BODY

      stub_request(:get, 'https://api.cased.com/events?page=1&per_page=25')
        .to_return(status: 403, body: body)

      assert_predicate query, :error?
    end

    def test_query_phrase_overrides_initializer_phrase
      ENV['CASED_ORGANIZATION_KEY'] = 'test'

      client = Cased.clients.organization
      query = Cased::Query.new(client, phrase: 'action:user.login')

      stub_request(:get, 'https://api.cased.com/events?page=1&per_page=25&phrase=action:user.logout')
        .to_return(status: 200)

      query.phrase('action:user.logout')

      assert_predicate query, :success?
    end

    def test_query_phrase
      ENV['CASED_ORGANIZATION_KEY'] = 'test'

      client = Cased.clients.organization
      query = Cased::Query.new(client)

      stub_request(:get, 'https://api.cased.com/events?page=1&per_page=25&phrase=action:user.login')
        .to_return(status: 200)

      query.phrase('action:user.login')

      assert_predicate query, :success?
    end

    def test_query_is_chainable
      ENV['CASED_ORGANIZATION_KEY'] = 'test'

      client = Cased.clients.organization
      query = Cased::Query.new(client)

      stub_request(:get, 'https://api.cased.com/events?page=87&per_page=49&phrase=action:user.logout')
        .to_return(status: 200)

      query.phrase('action:user.logout').limit(49).page(87)

      assert_predicate query, :success?
    end

    def test_query_page
      ENV['CASED_ORGANIZATION_KEY'] = 'test'

      client = Cased.clients.organization
      query = Cased::Query.new(client)

      stub_request(:get, 'https://api.cased.com/events?page=10&per_page=25')
        .to_return(status: 200)

      query.page(10)

      assert_predicate query, :success?
    end

    def test_query_page_positive_value
      ENV['CASED_ORGANIZATION_KEY'] = 'test'

      client = Cased.clients.organization
      query = Cased::Query.new(client)

      stub_request(:get, 'https://api.cased.com/events?page=1&per_page=25')
        .to_return(status: 200)

      query.page(-1)

      assert_predicate query, :success?
    end

    def test_query_limit
      ENV['CASED_ORGANIZATION_KEY'] = 'test'

      client = Cased.clients.organization
      query = Cased::Query.new(client)

      stub_request(:get, 'https://api.cased.com/events?page=1&per_page=5')
        .to_return(status: 200)

      query.limit(5)

      assert_predicate query, :success?
    end

    def test_query_limit_positive_value
      ENV['CASED_ORGANIZATION_KEY'] = 'test'

      client = Cased.clients.organization
      query = Cased::Query.new(client)

      stub_request(:get, 'https://api.cased.com/events?page=1&per_page=1')
        .to_return(status: 200)

      query.limit(-1)

      assert_predicate query, :success?
    end

    def test_query_limit_has_limit
      ENV['CASED_ORGANIZATION_KEY'] = 'test'

      client = Cased.clients.organization
      query = Cased::Query.new(client)

      stub_request(:get, 'https://api.cased.com/events?page=1&per_page=100')
        .to_return(status: 200)

      query.limit(101)

      assert_predicate query, :success?
    end

    def test_unsuccessful_query
      ENV['CASED_ORGANIZATION_KEY'] = 'test'

      client = Cased.clients.organization
      query = Cased::Query.new(client)

      stub_request(:get, 'https://api.cased.com/events?page=1&per_page=25')
        .to_return(status: 500)

      refute_predicate query, :success?
    end

    def test_does_not_raise_connection_failed
      ENV['CASED_ORGANIZATION_KEY'] = 'test'

      client = Faraday.new do |builder|
        builder.adapter :test do |stub|
          stub.get('/events') do
            raise Faraday::ConnectionFailed, nil
          end
        end
      end

      query = Cased::Query.new(client)

      refute_predicate query, :success?
      assert_predicate query, :error?
      assert_kind_of Faraday::ConnectionFailed, query.error
      assert_nil query.response.body
      assert_equal [], query.results
    end

    def test_does_not_raise_ssl_error
      ENV['CASED_ORGANIZATION_KEY'] = 'test'

      client = Faraday.new do |builder|
        builder.adapter :test do |stub|
          stub.get('/events') do
            raise Faraday::SSLError, nil
          end
        end
      end

      query = Cased::Query.new(client)

      refute_predicate query, :success?
      assert_predicate query, :error?
      assert_kind_of Faraday::SSLError, query.error
      assert_nil query.response.body
      assert_equal [], query.results
    end

    def test_query_audit_events
      ENV['CASED_ORGANIZATION_KEY'] = 'test'

      client = Cased.clients.organization
      query = Cased::Query.new(client)

      stub_request(:get, 'https://api.cased.com/events?page=1&per_page=25')
        .to_return(
          status: 200,
          headers: {
            'Content-Type' => 'application/json',
          },
          body: '{"results":[{"action": "user.login"}]}',
        )

      assert_equal [{ 'action' => 'user.login' }], query.results
    end

    def test_calling_results_executes_request
      ENV['CASED_ORGANIZATION_KEY'] = 'test'

      client = Cased.clients.organization
      query = Cased::Query.new(client)

      stub = stub_request(:get, 'https://api.cased.com/events?page=1&per_page=25')

      query.results

      assert_requested stub
    end

    def test_calling_total_count_executes_request
      ENV['CASED_ORGANIZATION_KEY'] = 'test'

      client = Cased.clients.organization
      query = Cased::Query.new(client)

      stub = stub_request(:get, 'https://api.cased.com/events?page=1&per_page=25')

      query.total_count

      assert_requested stub
    end

    def test_calling_total_pages_executes_request
      ENV['CASED_ORGANIZATION_KEY'] = 'test'

      client = Cased.clients.organization
      query = Cased::Query.new(client)

      stub = stub_request(:get, 'https://api.cased.com/events?page=1&per_page=25')

      query.total_pages

      assert_requested stub
    end

    def test_calling_next_page_url_guard_executes_request
      ENV['CASED_ORGANIZATION_KEY'] = 'test'

      client = Cased.clients.organization
      query = Cased::Query.new(client)

      stub = stub_request(:get, 'https://api.cased.com/events?page=1&per_page=25')

      query.next_page_url?

      assert_requested stub
    end

    def test_calling_next_page_url_executes_request
      ENV['CASED_ORGANIZATION_KEY'] = 'test'

      client = Cased.clients.organization
      query = Cased::Query.new(client)

      stub = stub_request(:get, 'https://api.cased.com/events?page=1&per_page=25')

      query.next_page_url

      assert_requested stub
    end

    def test_calling_next_page_executes_request
      ENV['CASED_ORGANIZATION_KEY'] = 'test'

      client = Cased.clients.organization
      query = Cased::Query.new(client)

      stub = stub_request(:get, 'https://api.cased.com/events?page=1&per_page=25')

      query.next_page

      assert_requested stub
    end

    def test_calling_next_page_guard_executes_request
      ENV['CASED_ORGANIZATION_KEY'] = 'test'

      client = Cased.clients.organization
      query = Cased::Query.new(client)

      stub = stub_request(:get, 'https://api.cased.com/events?page=1&per_page=25')

      query.next_page?

      assert_requested stub
    end

    def test_calling_previous_page_url_guard_executes_request
      ENV['CASED_ORGANIZATION_KEY'] = 'test'

      client = Cased.clients.organization
      query = Cased::Query.new(client)

      stub = stub_request(:get, 'https://api.cased.com/events?page=1&per_page=25')

      query.previous_page_url?

      assert_requested stub
    end

    def test_calling_previous_page_url_executes_request
      ENV['CASED_ORGANIZATION_KEY'] = 'test'

      client = Cased.clients.organization
      query = Cased::Query.new(client)

      stub = stub_request(:get, 'https://api.cased.com/events?page=1&per_page=25')

      query.previous_page_url

      assert_requested stub
    end

    def test_calling_previous_page_executes_request
      ENV['CASED_ORGANIZATION_KEY'] = 'test'

      client = Cased.clients.organization
      query = Cased::Query.new(client)

      stub = stub_request(:get, 'https://api.cased.com/events?page=1&per_page=25')

      query.previous_page

      assert_requested stub
    end

    def test_calling_previous_page_guard_executes_request
      ENV['CASED_ORGANIZATION_KEY'] = 'test'

      client = Cased.clients.organization
      query = Cased::Query.new(client)

      stub = stub_request(:get, 'https://api.cased.com/events?page=1&per_page=25')

      query.previous_page?

      assert_requested stub
    end

    def test_calling_first_page_url_guard_executes_request
      ENV['CASED_ORGANIZATION_KEY'] = 'test'

      client = Cased.clients.organization
      query = Cased::Query.new(client)

      stub = stub_request(:get, 'https://api.cased.com/events?page=1&per_page=25')

      query.first_page_url?

      assert_requested stub
    end

    def test_calling_first_page_url_executes_request
      ENV['CASED_ORGANIZATION_KEY'] = 'test'

      client = Cased.clients.organization
      query = Cased::Query.new(client)

      stub = stub_request(:get, 'https://api.cased.com/events?page=1&per_page=25')

      query.first_page_url

      assert_requested stub
    end

    def test_calling_first_page_executes_request
      ENV['CASED_ORGANIZATION_KEY'] = 'test'

      client = Cased.clients.organization
      query = Cased::Query.new(client)

      stub = stub_request(:get, 'https://api.cased.com/events?page=1&per_page=25')

      query.first_page

      assert_requested stub
    end

    def test_calling_first_page_guard_executes_request
      ENV['CASED_ORGANIZATION_KEY'] = 'test'

      client = Cased.clients.organization
      query = Cased::Query.new(client)

      stub = stub_request(:get, 'https://api.cased.com/events?page=1&per_page=25')

      query.first_page?

      assert_requested stub
    end

    def test_calling_last_page_url_guard_executes_request
      ENV['CASED_ORGANIZATION_KEY'] = 'test'

      client = Cased.clients.organization
      query = Cased::Query.new(client)

      stub = stub_request(:get, 'https://api.cased.com/events?page=1&per_page=25')

      query.last_page_url?

      assert_requested stub
    end

    def test_calling_last_page_url_executes_request
      ENV['CASED_ORGANIZATION_KEY'] = 'test'

      client = Cased.clients.organization
      query = Cased::Query.new(client)

      stub = stub_request(:get, 'https://api.cased.com/events?page=1&per_page=25')

      query.last_page_url

      assert_requested stub
    end

    def test_calling_last_page_executes_request
      ENV['CASED_ORGANIZATION_KEY'] = 'test'

      client = Cased.clients.organization
      query = Cased::Query.new(client)

      stub = stub_request(:get, 'https://api.cased.com/events?page=1&per_page=25')

      query.last_page

      assert_requested stub
    end

    def test_calling_last_page_guard_executes_request
      ENV['CASED_ORGANIZATION_KEY'] = 'test'

      client = Cased.clients.organization
      query = Cased::Query.new(client)

      stub = stub_request(:get, 'https://api.cased.com/events?page=1&per_page=25')

      query.last_page?

      assert_requested stub
    end

    def test_calling_error_executes_request
      ENV['CASED_ORGANIZATION_KEY'] = 'test'

      client = Cased.clients.organization
      query = Cased::Query.new(client)

      stub = stub_request(:get, 'https://api.cased.com/events?page=1&per_page=25')

      query.error

      assert_requested stub
    end

    def test_calling_error_guard_executes_request
      ENV['CASED_ORGANIZATION_KEY'] = 'test'

      client = Cased.clients.organization
      query = Cased::Query.new(client)

      stub = stub_request(:get, 'https://api.cased.com/events?page=1&per_page=25')

      query.error?

      assert_requested stub
    end

    def test_calling_success_executes_request
      ENV['CASED_ORGANIZATION_KEY'] = 'test'

      client = Cased.clients.organization
      query = Cased::Query.new(client)

      stub = stub_request(:get, 'https://api.cased.com/events?page=1&per_page=25')

      query.success?

      assert_requested stub
    end
  end
end
