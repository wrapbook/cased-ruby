# frozen_string_literal: true

require_relative './log_subscriber'

module Cased
  module Instrumentation
    module Controller
      extend ActiveSupport::Concern

      module ClassMethods
        def log_process_action(payload)
          messages = super
          count = payload[:cased_events]
          if count
            messages << format('Cased: %<count>d %<suffix>s', count: count, suffix: 'event'.pluralize(count))
          end
          messages
        end
      end

      protected

      def process_action(action, *args)
        Cased::Instrumentation::LogSubscriber.reset_events
        super
      end

      def append_info_to_payload(payload)
        super
        payload[:cased_events] = Cased::Instrumentation::LogSubscriber.events
      end
    end
  end
end
