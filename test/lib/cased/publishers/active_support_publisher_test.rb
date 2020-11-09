# frozen_string_literal: true

module Cased
  module Publishers
    class ActiveSupportPublisherTest < Cased::Test
      def test_publish_active_support_notification
        publisher = Cased::Publishers::ActiveSupportPublisher.new

        events = []
        ::ActiveSupport::Notifications.subscribe('event.cased') do |event|
          events << event
        end

        publisher.publish(action: 'user.login')

        assert_equal 1, events.length
      end
    end
  end
end
