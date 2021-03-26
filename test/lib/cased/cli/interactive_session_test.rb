# frozen_string_literal: true

require 'active_support/testing/assertions'

module Cased
  module CLI
    class InteractiveSessionTest < Cased::Test
      include ActiveSupport::Testing::Assertions

      def test_interactive_session
        old_guard_user_token = Cased.config.guard_user_token
        Cased.config.guard_user_token = 'user_1234'

        stub_request(:post, 'https://api.cased.com/cli/sessions')
          .to_return(
            status: 200,
            body: {
              id: 'session_1234',
              api_url: 'https://api.cased.com/cli/sessions/guard_session_1234',
              api_record_url: 'https://api.cased.com/cli/sessions/guard_session_1234/record',
              url: 'https://app.cased.com/cli/sessions/guard_session_1234',
              state: 'requested',
              reason: 'My reason',
              ip_address: '1.1.1.1',
              forwarded_ip_address: '127.0.0.1',
              command: 'irb',
              metadata: {
                user_agent: 'iPhone',
              },
              requester: {
                id: 'user_1234',
              },
              guard_application: {
                id: 'guard_application_1234',
              },
            }.to_json,
            headers: {
              'Content-Type' => 'application/json',
            },
          )

        stub_request(:get, 'https://api.cased.com/cli/sessions/guard_session_1234?user_token=user_1234')
          .to_return(
            status: 200,
            body: {
              id: 'session_1234',
              api_url: 'https://api.cased.com/cli/sessions/guard_session_1234',
              api_record_url: 'https://api.cased.com/cli/sessions/guard_session_1234/record',
              url: 'https://app.cased.com/cli/sessions/guard_session_1234',
              state: 'timed_out',
              reason: 'My reason',
              ip_address: '1.1.1.1',
              forwarded_ip_address: '127.0.0.1',
              command: 'irb',
              metadata: {
                user_agent: 'iPhone',
              },
              requester: {
                id: 'user_1234',
              },
              guard_application: {
                id: 'guard_application_1234',
              },
            }.to_json,
            headers: {
              'Content-Type' => 'application/json',
            },
          )

        begin
          Cased::CLI::InteractiveSession.start
          assert false, 'did not expect this to be reached'
        rescue SystemExit => error
          assert true
          assert_equal 1, error.status
          assert_not error.success?
        end
      ensure
        Cased.config.guard_user_token = old_guard_user_token
      end
    end
  end
end
