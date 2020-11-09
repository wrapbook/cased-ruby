# frozen_string_literal: true

# ActiveSupport::Notifications will fail if concurrent isn't loaded
require 'concurrent'
require 'active_support/notifications'
require 'cased/publishers/base'

module Cased
  module Publishers
    class ActiveSupportPublisher < Base
      def publish(event)
        ::ActiveSupport::Notifications.instrument('event.cased', event: event)
      end
    end
  end
end
