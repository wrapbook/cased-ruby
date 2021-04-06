# frozen_string_literal: true

require 'active_support/testing/assertions'

module Cased
  module CLI
    class SessionTest < Cased::Test
      include ActiveSupport::Testing::Assertions

      def stub_session(options = {})
        stub_request(:get, 'https://api.cased.com/cli/sessions/guard_session_1234?user_token=user_1234')
          .to_return(
            status: 200,
            body: {
              id: 'session_1234',
              api_url: 'https://api.cased.com/cli/sessions/guard_session_1234',
              api_record_url: 'https://api.cased.com/cli/sessions/guard_session_1234/record',
              url: 'https://app.cased.com/cli/sessions/guard_session_1234',
              state: 'requested',
              reason: '',
              ip_address: '1.1.1.1',
              forwarded_ip_address: '127.0.0.1',
              command: 'irb',
              metadata: {},
              requester: {
                id: 'user_1234',
              },
              guard_application: {
                id: 'guard_application_1234',
              },
            }.merge(options).to_json,
            headers: {
              'Content-Type' => 'application/json',
            },
          )
      end

      def test_find
        old_guard_user_token = Cased.config.guard_user_token
        Cased.config.guard_user_token = 'user_1234'
        stub_session

        session = Cased::CLI::Session.find('guard_session_1234')

        assert_equal 'user_1234', session.requester['id']
      ensure
        Cased.config.guard_user_token = old_guard_user_token
      end

      def test_to_s
        session = Cased::CLI::Session.new(command: 'irb')

        assert_equal 'irb', session.to_s
      end

      def test_to_param
        old_guard_user_token = Cased.config.guard_user_token
        Cased.config.guard_user_token = 'user_1234'
        stub_session

        session = Cased::CLI::Session.find('guard_session_1234')

        assert_equal 'session_1234', session.to_param
      ensure
        Cased.config.guard_user_token = old_guard_user_token
      end

      def test_state_requested
        old_guard_user_token = Cased.config.guard_user_token
        Cased.config.guard_user_token = 'user_1234'
        stub_session(state: 'requested')

        session = Cased::CLI::Session.find('guard_session_1234')

        assert_equal 'requested', session.state
        assert_predicate session, :requested?
      ensure
        Cased.config.guard_user_token = old_guard_user_token
      end

      def test_state_approved
        old_guard_user_token = Cased.config.guard_user_token
        Cased.config.guard_user_token = 'user_1234'
        stub_session(state: 'approved')

        session = Cased::CLI::Session.find('guard_session_1234')

        assert_equal 'approved', session.state
        assert_predicate session, :approved?
      ensure
        Cased.config.guard_user_token = old_guard_user_token
      end

      def test_state_denied
        old_guard_user_token = Cased.config.guard_user_token
        Cased.config.guard_user_token = 'user_1234'
        stub_session(state: 'denied')

        session = Cased::CLI::Session.find('guard_session_1234')

        assert_equal 'denied', session.state
        assert_predicate session, :denied?
      ensure
        Cased.config.guard_user_token = old_guard_user_token
      end

      def test_state_canceled
        old_guard_user_token = Cased.config.guard_user_token
        Cased.config.guard_user_token = 'user_1234'
        stub_session(state: 'canceled')

        session = Cased::CLI::Session.find('guard_session_1234')

        assert_equal 'canceled', session.state
        assert_predicate session, :canceled?
      ensure
        Cased.config.guard_user_token = old_guard_user_token
      end

      def test_state_timed_out
        old_guard_user_token = Cased.config.guard_user_token
        Cased.config.guard_user_token = 'user_1234'
        stub_session(state: 'timed_out')

        session = Cased::CLI::Session.find('guard_session_1234')

        assert_equal 'timed_out', session.state
        assert_predicate session, :timed_out?
      ensure
        Cased.config.guard_user_token = old_guard_user_token
      end

      def test_refresh
        old_guard_user_token = Cased.config.guard_user_token
        Cased.config.guard_user_token = 'user_1234'
        stub_session(state: 'requested')

        session = Cased::CLI::Session.find('guard_session_1234')

        assert_equal 'requested', session.state
        assert_predicate session, :requested?

        stub_session(state: 'approved')
        session.refresh

        assert_equal 'approved', session.state
        assert_predicate session, :approved?
      ensure
        Cased.config.guard_user_token = old_guard_user_token
      end

      def test_error_unauthorized
        old_guard_user_token = Cased.config.guard_user_token
        Cased.config.guard_user_token = 'user_1234'
        stub_session(state: 'requested')
        stub_request(:post, 'https://api.cased.com/cli/sessions')
          .to_return(
            status: 401,
            body: {
              error: 'unauthorized',
            }.to_json,
            headers: {
              'Content-Type' => 'application/json',
            },
          )

        session = Cased::CLI::Session.new

        refute session.create
        assert_predicate session, :unauthorized?
        assert_predicate session, :error?
      ensure
        Cased.config.guard_user_token = old_guard_user_token
      end

      def test_error_reauthenticate
        old_guard_user_token = Cased.config.guard_user_token
        Cased.config.guard_user_token = 'user_1234'
        stub_session(state: 'requested')
        stub_request(:post, 'https://api.cased.com/cli/sessions')
          .to_return(
            status: 401,
            body: {
              error: 'reauthenticate',
            }.to_json,
            headers: {
              'Content-Type' => 'application/json',
            },
          )

        session = Cased::CLI::Session.new

        refute session.create
        assert_predicate session, :reauthenticate?
        assert_predicate session, :error?
      ensure
        Cased.config.guard_user_token = old_guard_user_token
      end

      def test_error_reason_required
        old_guard_user_token = Cased.config.guard_user_token
        Cased.config.guard_user_token = 'user_1234'
        stub_session(state: 'requested')
        stub_request(:post, 'https://api.cased.com/cli/sessions')
          .to_return(
            status: 400,
            body: {
              error: 'reason_required',
            }.to_json,
            headers: {
              'Content-Type' => 'application/json',
            },
          )

        session = Cased::CLI::Session.new

        refute session.create
        assert_predicate session, :reason_required?
        assert_predicate session, :error?
      ensure
        Cased.config.guard_user_token = old_guard_user_token
      end

      def test_unknown_error
        old_guard_user_token = Cased.config.guard_user_token
        Cased.config.guard_user_token = 'user_1234'
        stub_session(state: 'requested')
        stub_request(:post, 'https://api.cased.com/cli/sessions')
          .to_return(
            status: 499,
            body: {
              error: 'another',
            }.to_json,
            headers: {
              'Content-Type' => 'application/json',
            },
          )

        session = Cased::CLI::Session.new

        refute session.create
        refute_predicate session, :reason_required?
        assert_predicate session, :error?
      ensure
        Cased.config.guard_user_token = old_guard_user_token
      end

      def test_success
        old_guard_user_token = Cased.config.guard_user_token
        Cased.config.guard_user_token = 'user_1234'
        stub_session(state: 'requested')
        stub_request(:post, 'https://api.cased.com/cli/sessions')
          .to_return(
            status: 200,
            body: {
              id: 'session_1234',
              api_url: 'https://api.cased.com/cli/sessions/guard_session_1234',
              api_record_url: 'https://api.cased.com/cli/sessions/guard_session_1234/record',
              url: 'https://app.cased.com/cli/sessions/guard_session_1234',
              state: 'requested',
              reason: '',
              ip_address: '1.1.1.1',
              forwarded_ip_address: '127.0.0.1',
              command: 'irb',
              metadata: {},
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

        session = Cased::CLI::Session.new

        assert session.create
        assert_predicate session, :success?
      ensure
        Cased.config.guard_user_token = old_guard_user_token
      end

      def test_reason_required_from_request
        old_guard_user_token = Cased.config.guard_user_token
        Cased.config.guard_user_token = 'user_1234'
        stub_session(
          guard_application: {
            settings: {
              reason_required: true,
            },
          },
        )

        session = Cased::CLI::Session.find('guard_session_1234')

        assert_predicate session, :reason_required?
        refute_predicate session, :error?
      ensure
        Cased.config.guard_user_token = old_guard_user_token
      end

      def test_should_record_output
        old_guard_user_token = Cased.config.guard_user_token
        Cased.config.guard_user_token = 'user_1234'
        stub_session(
          guard_application: {
            settings: {
              record_output: true,
            },
          },
        )

        session = Cased::CLI::Session.find('guard_session_1234')

        assert_predicate session, :record_output?
      ensure
        Cased.config.guard_user_token = old_guard_user_token
      end

      def test_should_not_record_output
        old_guard_user_token = Cased.config.guard_user_token
        Cased.config.guard_user_token = 'user_1234'
        stub_session(
          guard_application: {
            settings: {
              record_output: false,
            },
          },
        )

        session = Cased::CLI::Session.find('guard_session_1234')

        refute_predicate session, :record_output?
      ensure
        Cased.config.guard_user_token = old_guard_user_token
      end

      def test_create
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
        session = Cased::CLI::Session.new

        assert session.create
        assert_equal 'session_1234', session.id
        assert_equal 'https://api.cased.com/cli/sessions/guard_session_1234', session.api_url
        assert_equal 'https://api.cased.com/cli/sessions/guard_session_1234/record', session.api_record_url
        assert_equal 'https://app.cased.com/cli/sessions/guard_session_1234', session.url
        assert_equal 'requested', session.state
        assert_equal 'My reason', session.reason
        assert_equal '1.1.1.1', session.ip_address
        assert_equal '127.0.0.1', session.forwarded_ip_address
        assert_equal 'irb', session.command
        assert_equal 'iPhone', session.metadata['user_agent']
        assert_equal 'user_1234', session.requester['id']
        assert_equal 'guard_application_1234', session.guard_application['id']
      ensure
        Cased.config.guard_user_token = old_guard_user_token
      end

      def test_cancel
        old_guard_user_token = Cased.config.guard_user_token
        Cased.config.guard_user_token = 'user_1234'
        stub_session(state: 'requested')
        stub_request(:post, 'https://api.cased.com/cli/sessions/guard_session_1234/cancel')
          .to_return(
            status: 200,
            body: {
              id: 'session_1234',
              api_url: 'https://api.cased.com/cli/sessions/guard_session_1234',
              api_record_url: 'https://api.cased.com/cli/sessions/guard_session_1234/record',
              url: 'https://app.cased.com/cli/sessions/guard_session_1234',
              state: 'canceled',
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
        session = Cased::CLI::Session.find('guard_session_1234')

        refute_predicate session, :canceled?
        assert session.cancel
        assert_predicate session, :canceled?
      ensure
        Cased.config.guard_user_token = old_guard_user_token
      end

      def test_cased_category
        session = Cased::CLI::Session.new

        assert_equal :cli, session.cased_category
      end

      def test_cased_id
        old_guard_user_token = Cased.config.guard_user_token
        Cased.config.guard_user_token = 'user_1234'
        stub_session(state: 'requested')
        stub_request(:post, 'https://api.cased.com/cli/sessions/guard_session_1234/cancel')
          .to_return(
            status: 200,
            body: {
              id: 'session_1234',
              api_url: 'https://api.cased.com/cli/sessions/guard_session_1234',
              api_record_url: 'https://api.cased.com/cli/sessions/guard_session_1234/record',
              url: 'https://app.cased.com/cli/sessions/guard_session_1234',
              state: 'canceled',
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
        session = Cased::CLI::Session.find('guard_session_1234')

        assert_equal 'session_1234', session.cased_id
      ensure
        Cased.config.guard_user_token = old_guard_user_token
      end

      def test_cased_context
        old_guard_user_token = Cased.config.guard_user_token
        Cased.config.guard_user_token = 'user_1234'
        stub_session(state: 'requested')
        stub_request(:post, 'https://api.cased.com/cli/sessions/guard_session_1234/cancel')
          .to_return(
            status: 200,
            body: {
              id: 'session_1234',
              api_url: 'https://api.cased.com/cli/sessions/guard_session_1234',
              api_record_url: 'https://api.cased.com/cli/sessions/guard_session_1234/record',
              url: 'https://app.cased.com/cli/sessions/guard_session_1234',
              state: 'canceled',
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
        session = Cased::CLI::Session.find('guard_session_1234')

        expected_context = {
          cli: 'irb',
          cli_id: 'session_1234',
        }

        assert_equal expected_context, session.cased_context
      ensure
        Cased.config.guard_user_token = old_guard_user_token
      end

      def test_current
        old_guard_user_token = Cased.config.guard_user_token
        Cased.config.guard_user_token = 'user_1234'
        stub_session(state: 'requested')

        refute Cased::CLI::Session.current?
        old_guard_session_id = ENV['GUARD_SESSION_ID']
        ENV['GUARD_SESSION_ID'] = 'guard_session_1234'
        assert Cased::CLI::Session.current?
        assert_equal 'session_1234', Cased::CLI::Session.current.id
      ensure
        Cased.config.guard_user_token = old_guard_user_token
        ENV['GUARD_SESSION_ID'] = old_guard_session_id
      end

      def test_new_with_global_config
        metadata = { application: 'my_app' }
        Cased.config.cli.metadata = metadata
        session = Cased::CLI::Session.new

        assert_equal metadata, session.metadata
      end
    end
  end
end
