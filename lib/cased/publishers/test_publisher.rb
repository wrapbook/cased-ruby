# frozen_string_literal: true

require 'cased/publishers/base'

module Cased
  module Publishers
    class TestPublisher < Base
      attr_reader :events

      def initialize
        @events = []
      end

      def publish(event)
        @events << event
      end
    end
  end
end
