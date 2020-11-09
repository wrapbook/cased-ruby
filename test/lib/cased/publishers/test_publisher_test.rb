# frozen_string_literal: true

module Cased
  module Publishers
    class TestPublisherTest < Cased::Test
      def test_publish_event
        publisher = Cased::Publishers::TestPublisher.new
        publisher.publish(action: 'user.login')

        expected_events = [
          {
            action: 'user.login',
          },
        ]

        assert_equal expected_events, publisher.events
      end
    end
  end
end
