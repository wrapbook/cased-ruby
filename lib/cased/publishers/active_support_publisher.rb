# frozen_string_literal: true

# ActiveSupport::Notifications will fail if concurrent isn't loaded
require 'concurrent'
require 'active_support/notifications'
require 'cased/publishers/base'

begin
  require 'active_support/isolated_execution_state'
rescue LoadError
  # This is required for ActiveSupport 7.0 but not present in 6.1
end

module Cased
  module Publishers
    class ActiveSupportPublisher < Base
      def publish(event)
        ::ActiveSupport::Notifications.instrument('event.cased', event: event)
      end
    end
  end
end
