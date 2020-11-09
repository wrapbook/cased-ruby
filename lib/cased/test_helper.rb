# frozen_string_literal: true

require 'active_support/core_ext/hash/keys'

module Cased
  module TestHelper
    def before_setup
      @original_cased_publishers = Cased.publishers
      Cased.publishers = [
        cased_test_publisher,
      ]

      clear_cased_events
      clear_cased_context
      super
    end

    def after_teardown
      super

      Cased.publishers = @original_cased_publishers
    end

    # Clears all published events in the test Cased publisher
    def clear_cased_events
      cased_events.clear
    end

    def clear_cased_context
      Cased::Context.clear!
    end

    def cased_events
      cased_test_publisher.events
    end

    # Assertion that helps with testing that a number of events have been published to Cased.
    #
    # @param expected_event_count [Integer] The number of expected Cased events to be published.
    # @param expected_event_body [Hash] Expected event to be published to Cased.
    #
    # @example Expected events with a filter inside of a block
    #   def test_creates_user_create_event
    #     assert_cased_events 1, action: 'user.create' do
    #       create(:user)
    #     end
    #   end
    #
    # @example Expected events without a filter inside of a block
    #   def test_creates_user_create_event
    #     assert_cased_events 1 do
    #       create(:user)
    #     end
    #   end
    #
    # @example Expected events with a filter for the duration of the test
    #   def test_creates_user_create_event
    #     create(:user)
    #
    #     assert_cased_events 1, action: 'user.create'
    #   end
    #
    # @example Expected events without a filter for the duration of the test
    #   def test_creates_user_create_event
    #     create(:user)
    #
    #     assert_cased_events 1
    #   end
    #
    # @example Cased::Model value hash
    #   def test_creates_user_create_event
    #     user = create(:user)
    #
    #     assert_cased_events 1, action: 'user.login', user: user
    #   end
    #
    # @return [void]
    def assert_cased_events(expected_event_count, expected_event_body = nil, &block)
      expected_event_body&.deep_symbolize_keys!

      actual_event_count = if block
        events_before_block = cased_events_with(expected_event_body)

        block&.call

        events_after_block = cased_events_with(expected_event_body)

        events_after_block.length - events_before_block.length
      else
        cased_events_with(expected_event_body).length
      end

      assert_equal expected_event_count, actual_event_count, "#{expected_event_count} Cased published events expected, but #{actual_event_count} were published"
    end

    # Assertion that expects there to have been zero matching Cased events.
    #
    # @param expected_event_body [Hash] Expected event not to be published to Cased.
    #
    # @example Expected no events with a filter inside of a block
    #   def test_creates_bot_account
    #     assert_no_cased_events action: 'bot.create' do
    #       create(:bot)
    #     end
    #   end
    #
    # @example Expected no events inside of a block
    #   def test_creates_bot_account
    #     assert_no_cased_events do
    #       create(:bot)
    #     end
    #   end
    #
    # @example Expected no events containing a subset of the event body for the duration of the test
    #   def test_creates_bot_account
    #     create(:bot)
    #
    #     assert_no_cased_events action: 'bot.create'
    #   end
    #
    # @example Expected no events for the duration of the test
    #   def test_creates_bot_account
    #     create(:bot)
    #
    #     assert_no_cased_events
    #   end
    #
    # @return [void]
    def assert_no_cased_events(expected_event_body = nil, &block)
      assert_cased_events(0, expected_event_body, &block)
    end

    # Locates all published events matching a particular shape.
    #
    # @param expected_event [Hash] the shape of event expected to be published to Cased
    #
    # @example Simple hash
    #   cased_events_with(action: 'user.login') # => [{ action: 'user.login', actor: 'garrett@cased.com' }, { action: 'user.login', actor: 'ted@cased.com' }]
    #
    # @example Nested hash
    #   cased_events_with(issues: [{ issue_id: 1 }]) # => [{ action: 'user.login', issues: [{ issue_id: 1 }, { issue_id: 2 }]}]
    #
    # @example Cased::Model value hash
    #   user = User.new
    #   user.cased_context # => { user: 'garrett@cased.com', user_id: 'user_1234' }
    #   cased_events_with(user: user) # => [{ user: 'garrett@cased.com', user_id: 'user_1234' }]
    #
    # @return [Array<Hash>] Array of matching published Cased events.
    # @raises [ArgumentError] if expected_event is empty.
    def cased_events_with(expected_event = {})
      return cased_events.dup if expected_event.nil?

      if expected_event.empty?
        raise ArgumentError, 'You must call cased_events_with with a non empty Hash otherwise it will match all events'
      end

      expanded_expected_event = Cased::Context::Expander.expand(expected_event)
      if expanded_expected_event.empty?
        raise ArgumentError, <<~MSG.strip
          cased_events_with would have matched any published Cased event.

          cased_events_with was called with #{expected_event.inspect} but resulted into #{expanded_expected_event} after it was expanded.

          This typically happens when an object that includes Cased::Model does not implement either the #cased_id or #to_s method.
        MSG
      end

      # We need to normalize input as it could be a mix of strings and symbols.
      expected_event.deep_symbolize_keys!
      expanded_expected_event = expanded_expected_event.to_a

      events = cased_events.dup.collect(&:deep_symbolize_keys).collect(&:to_a)
      matching_events = events.select do |event|
        diff = expanded_expected_event - event
        diff.empty?
      end

      matching_events.collect(&:to_h)
    end

    # The test published used for the duration of the test.
    #
    # @return [Cased::Publishers::TestPublisher]
    def cased_test_publisher
      @cased_test_publisher ||= Cased::Publishers::TestPublisher.new
    end
  end
end
