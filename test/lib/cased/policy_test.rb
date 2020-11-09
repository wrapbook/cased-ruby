# frozen_string_literal: true

module Cased
  class PolicyTest < Cased::Test
    def test_build_policy_query
      policy = Cased::Policy.new(api_key: 'key')

      assert_kind_of Cased::Query, policy.events
    end

    def test_configures_policy_with_api_key
      stub_request(:get, 'https://api.cased.com/events/12345')
        .to_return(
          status: 200,
          headers: {
            'Authorization' => 'Bearer custom_organization_key',
            'Content-Type' => 'application/json',
          },
          body: '{"action": "user.login"}',
        )

      policy = Cased::Policy.new(api_key: 'custom_organization_key')
      event = policy.event('12345')

      assert_equal 'user.login', event['action']
    end

    def test_retrieving_event
      stub_request(:get, 'https://api.cased.com/events/12345')
        .to_return(
          status: 200,
          headers: {
            'Authorization' => 'Bearer test',
            'Content-Type' => 'application/json',
          },
          body: '{"action": "user.login"}',
        )

      policy = Cased::Policy.new(api_key: 'test')
      event = policy.event('12345')

      assert_equal 'user.login', event['action']
    end
  end
end
