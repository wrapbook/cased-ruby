# frozen_string_literal: true

require 'cased/guard/authentication'
require 'cased/guard/identity'

module Cased
  module Guard
    class Session
      # @return [Cased::Guard::Authentication]
      attr_reader :authentication

      # Public: The Guard session ID
      # @example
      #   session.id #=> "guard_session_1oFqm5GBQYwhH8pfIpnS0A5QgFJ"
      # @return [String, nil]
      attr_reader :id

      # Public: The Guard session web URL
      # @example
      #   session.url #=> "https://api.cased.com/guard/programs/ruby/sessions/guard_session_1oFqm5GBQYwhH8pfIpnS0A5QgFJ"
      # @return [String, nil]
      attr_reader :url

      # Public: The Guard session API URL
      # @example
      #   session.api_url #=> "https://api.cased.com/guard/sessions/guard_session_1oFqm5GBQYwhH8pfIpnS0A5QgFJ"
      # @return [String, nil]
      attr_reader :api_url

      # Public: The current state the Guard session is in
      # @example
      #   session.api_url #=> "approved"
      # @return [String, nil]
      attr_reader :state

      # Public: Additional user supplied metadata about the Guard session.
      # @example
      #   session.metadata #=> {"hostname" => "Mac.local"}
      # @return [Hash]
      attr_accessor :metadata

      # Public: The user supplied reason for the Guard session for taking place.
      # @example
      #   session.reason #=> "Investigating customer support ticket."
      # @return [String, nil]
      attr_accessor :reason

      # Public: The client's IP V4 or IP V6 address that initiated the Guard session.
      # @example
      #   session.reason #=> "1.1.1.1"
      # @return [String, nil]
      attr_reader :ip_address

      # Public: The Cased user that requested the Guard session.
      # @example
      #   session.requester #=> {"id" => "user_1oFqlROLNRGVLOXJSsHkJiVmylr"}
      # @return [Hash, nil]
      attr_reader :requester

      # Public: The Cased user that requested the Guard session.
      # @example
      #   session.responded_at #=> "2021-02-10 12:08:44 -0800"
      # @return [Time, nil]
      attr_reader :responded_at

      # Public: The Cased user that responded to the Guard session.
      # @example
      #   session.responder #=> {"id" => "user_1oFqlROLNRGVLOXJSsHkJiVmylr"}
      # @return [Hash, nil]
      attr_reader :responder

      # Public: The Guard application that the Guard session belongs to.
      # @example
      #   session.guard_application #=> {"id" => "guard_application_1oFqltbMqSEtJQKRCAYQNrQoXsS"}
      # @return [Hash, nil]
      attr_reader :guard_application

      def initialize(reason: nil, metadata: {})
        @authentication = Cased::Guard::Authentication.new
        @id = nil
        @reason = reason
        @metadata = metadata
      end

      def session=(session)
        @id = session.fetch('id')
        @api_url = session.fetch('api_url')
        @url = session.fetch('url')
        @state = session.fetch('state')
        @metadata = session.fetch('metadata')
        @reason = session.fetch('reason')
        @ip_address = session.fetch('ip_address')
        @requester = session.fetch('requester')
        @responded_at = session['responded_at']
        @responder = session['responder']
        @guard_application = session.fetch('guard_application')
      end

      def refresh
        response = Cased.clients.guard.get(api_url, user_token: authentication.token)
        self.session = response.body if response.success?
      end

      def create
        return false unless id.nil?

        response = Cased.clients.guard.post('guard/sessions', user_token: authentication.token, reason: reason, metadata: metadata)
        self.session = response.body if response.success?

        response.success?
      end
    end
  end
end
