# frozen_string_literal: true

require 'test_helper'
require 'active_support/testing/assertions'
require 'active_support/testing/time_helpers'

class User
  include Cased::Model

  def cased_id
    'User;1'
  end
end

class CasedTest < Cased::Test
  include ActiveSupport::Testing::Assertions
  include ActiveSupport::Testing::TimeHelpers

  def test_default_policy
    old_api_key = Cased.config.policy_key

    assert_nil Cased.policy.api_key
  ensure
    Cased.policies.delete(:default)
    Cased.config.policy_key = old_api_key
  end

  def test_default_policy_with_key
    old_api_key = Cased.config.policy_key

    Cased.config.policy_key = 'default-policy-key'

    assert_equal 'default-policy-key', Cased.policy.api_key
  ensure
    Cased.policies.delete(:default)
    Cased.config.policy_key = old_api_key
  end

  def test_loads_policy_from_environment
    old_api_key = ENV['CASED_ORGANIZATION_POLICY_API_KEY']

    ENV['CASED_ORGANIZATION_POLICY_API_KEY'] = 'test'

    assert_kind_of Cased::Policy, Cased.policies[:organization]
  ensure
    Cased.policies.delete(:organization)
    ENV['CASED_ORGANIZATION_POLICY_API_KEY'] = old_api_key
  end

  def test_can_generate_resource_identifier
    user = User.new
    assert_equal 'User;1', Cased.id(user)
  end

  def test_can_configure_client_using_block
    old_http_open_timeout = Cased.config.http_open_timeout

    refute_equal 15, old_http_open_timeout

    Cased.configure do |config|
      config.http_open_timeout = 15
    end

    assert_equal 15, Cased.config.http_open_timeout
  ensure
    Cased.config.http_open_timeout = old_http_open_timeout
  end

  def test_clients_can_access_api_and_publish_endpoint
    old_organization_key = ENV['CASED_ORGANIZATION_KEY']
    old_publish_key = ENV['CASED_PUBLISH_KEY']

    ENV['CASED_ORGANIZATION_KEY'] = 'test'
    ENV['CASED_PUBLISH_KEY'] = 'test'

    assert_kind_of Cased::HTTP::Client, Cased.clients.organization
    assert_kind_of Cased::HTTP::Client, Cased.clients.publish
  ensure
    ENV['CASED_ORGANIZATION_KEY'] = old_organization_key
    ENV['CASED_PUBLISH_KEY'] = old_publish_key
  end

  def test_starting_console_session_adds_hostname_to_context
    Cased::Context.clear!

    Cased.console

    assert_equal Socket.gethostname, Cased.context[:location]
  end

  def test_process_does_not_mutate_context
    old_publishers = Cased.publishers
    test_publisher = Cased::Publishers::TestPublisher.new
    Cased.publishers = [test_publisher]

    Cased::Context.current = { location: 'testing.local' }

    Cased.publish(action: 'user.login')

    expected_context = {
      location: 'testing.local',
    }
    assert_equal expected_context, Cased.context.context
  ensure
    Cased.publishers = old_publishers
  end

  def test_process_injects_sensitive_information
    old_handlers = Cased::Sensitive::Handler.handlers
    old_publishers = Cased.publishers
    test_publisher = Cased::Publishers::TestPublisher.new
    Cased.publishers = [test_publisher]

    Cased.sensitive(:phone_number, /\d{3}\-\d{3}\-\d{4}/)

    travel_to(Time.utc(2020, 1, 1)) do
      Cased.publish(action: 'user.login', body: 'Hello 111-222-3333')
    end

    expected_event = {
      action: 'user.login',
      body: 'Hello 111-222-3333',
      timestamp: '2020-01-01T00:00:00.000000Z',
      '.cased': {
        pii: {
          '.body': [
            {
              label: :phone_number,
              begin: 6,
              end: 18,
            },
          ],
        },
      },
    }

    audit_event = test_publisher.events.pop
    actual_event = audit_event.except(:cased_id)
    assert_equal expected_event, actual_event
  ensure
    Cased::Sensitive::Handler.handlers = old_handlers
    Cased.publishers = old_publishers
  end

  def test_registering_sensitive_handler
    assert_difference 'Cased::Sensitive::Handler.handlers.length' do
      Cased.sensitive(:username, /\@\w+/)
    end
  end

  def test_publishers_does_not_stop_execution_if_invalid_publisher_when_raise_on_errors_is_false
    old_publishers = Cased.publishers
    test_publisher = Cased::Publishers::TestPublisher.new
    Cased.publishers = [String.new, test_publisher]
    refute_predicate Cased.config, :raise_on_errors?

    assert_difference 'test_publisher.events.length' do
      suppress_output do
        Cased.publish(action: 'user.login')
      end
    end
  ensure
    Cased.publishers = old_publishers
  end

  def test_publishers_stops_execution_if_invalid_publisher_when_raise_on_errors_is_true
    old_raise_on_errors = Cased.config.raise_on_errors?
    old_publishers = Cased.publishers
    test_publisher = Cased::Publishers::TestPublisher.new
    Cased.publishers = [String.new, test_publisher]

    Cased.config.raise_on_errors = true

    exception = assert_raises(ArgumentError) do
      Cased.publish(action: 'user.login')
    end

    assert_equal 'String must implement String#publish', exception.message
    assert_empty test_publisher.events
  ensure
    Cased.publishers = old_publishers
    Cased.config.raise_on_errors = old_raise_on_errors
  end

  def test_can_set_exception_handler_to_nil
    Cased.exception_handler = nil
  end

  def test_can_not_set_exception_handler_with_proc_that_has_no_arguments
    old_exception_handler = Cased.exception_handler

    assert_raises(ArgumentError) do
      Cased.exception_handler = -> {}
    end
  ensure
    Cased.exception_handler = old_exception_handler
  end

  def test_setting_exception_handler_to_invalid_interface
    old_exception_handler = Cased.exception_handler

    exception = assert_raises(ArgumentError) do
      Cased.exception_handler = String.new
    end

    assert_equal 'String does not respond to #call', exception.message
  ensure
    Cased.exception_handler = old_exception_handler
  end

  def test_calls_exception_handler
    old_exception_handler = Cased.exception_handler
    original_raise_on_errors = Cased.config.raise_on_errors?
    Cased.config.raise_on_errors = false

    @buffer = []
    assert_empty @buffer
    Cased.exception_handler = ->(arg) { @buffer << arg }

    Cased.handle_exception(ArgumentError.new)

    refute_empty @buffer
  ensure
    Cased.exception_handler = old_exception_handler
    Cased.config.raise_on_errors = original_raise_on_errors
  end

  def test_can_silence_events
    # The test environment by default is silent
    original_silence = Cased.config.silence?
    Cased.config.silence = false
    old_publishers = Cased.publishers
    test_publisher = Cased::Publishers::TestPublisher.new
    Cased.publishers = [test_publisher]

    refute_predicate Cased.config, :silence?

    Cased.silence do
      assert_predicate Cased.config, :silence?
      Cased.publish(action: 'user.login')
    end

    assert_empty test_publisher.events
    refute_predicate Cased.config, :silence?
  ensure
    Cased.publishers = old_publishers
    Cased.config.silence = original_silence
  end

  def test_can_silence_events_with_environment_variable
    # The test environment by default is silent
    old_publishers = Cased.publishers
    test_publisher = Cased::Publishers::TestPublisher.new
    Cased.publishers = [test_publisher]

    refute_predicate Cased.config, :silence?

    ENV['CASED_SILENCE'] = 'true'
    assert_predicate Cased.config, :silence?
    Cased.publish(action: 'user.login')

    assert_empty test_publisher.events
  ensure
    ENV['CASED_SILENCE'] = nil
    Cased.publishers = old_publishers
  end

  class MutatingPublisher < Cased::Publishers::Base
    def publish(event)
      event[:action] = 'user.logout'
    end
  end

  def test_publishers_set_to_nil_sets_default_publishers
    Cased.publishers = nil

    expected_publishers = [
      Cased::Publishers::HTTPPublisher.new,
      Cased::Publishers::ActiveSupportPublisher.new,
    ]

    assert_equal expected_publishers, Cased.publishers
  end

  def test_publish_does_not_allow_mutating_payload_between_publishers
    old_publishers = Cased.publishers
    audit_event = { action: 'user.login' }
    Cased.publishers = [MutatingPublisher.new]

    Cased.publish(audit_event)

    assert_equal 'user.login', audit_event[:action]
  ensure
    Cased.publishers = old_publishers
  end
end
