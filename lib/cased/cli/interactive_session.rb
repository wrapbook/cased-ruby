# frozen_string_literal: true

require 'cased/cli/session'

module Cased
  module CLI
    class InteractiveSession
      attr_reader :session

      def initialize(reason: nil, metadata: {})
        @session = Cased::CLI::Session.new(reason: reason, metadata: metadata)
      end

      def create
        if session.create
          handle_state(session.state)
        else
          puts 'Could not create session'
        end
      rescue Cased::HTTP::Error::Unauthorized
        if session.authentication.exists?
          puts "Existing credentials at #{session.authentication.credentials_path} are not valid."
        else
          puts "Could not find credentials at #{session.authentication.credentials_path}, looking up now…"
        end

        identity = Cased::CLI::Identity.new
        session.authentication.token = identity.identify

        retry
      rescue Cased::HTTP::Error::BadRequest => e
        case e.json['error']
        when 'reason_required'
          reason_prompt && retry
        else
          raise
        end
      end

      private

      def reason_prompt
        print 'Enter a reason: '
        session.reason = gets.chomp
      end

      def wait_for_approval
        session.refresh && handle_state(session.state)
      end

      def handle_state(state)
        case state
        when 'approved'
          puts 'Session has been approved'
        when 'requested'
          wait_for_approval
        when 'denied'
          puts 'Session has been denied'
        when 'timed_out'
          puts 'Session has timed out'
        when 'canceled'
          puts 'Session has been canceled'
        end
      end
    end
  end
end
