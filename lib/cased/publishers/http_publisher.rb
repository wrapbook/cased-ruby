# frozen_string_literal: true

require 'cased/publishers/base'

module Cased
  module Publishers
    class HTTPPublisher < Base
      def publish(audit_event)
        Cased.clients.publish.post do |req|
          req.body = JSON.generate(audit_event)
        end
      end
    end
  end
end
