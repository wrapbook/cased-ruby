# frozen_string_literal: true

require 'cased/cli/authentication'
require 'cased/cli/identity'
require 'cased/cli/recorder'
require 'cased/model'

module Cased
  module CLI
    class Session
      include Cased::Model

      def self.find(guard_session_id)
        authentication = Cased::CLI::Authentication.new

        response = Cased.clients.cli.get("cli/sessions/#{guard_session_id}", user_token: authentication.token)
        new.tap do |session|
          session.session = response.body
        end
      end

      # If we're inside of a recorded session we can lookup the session
      # we're in.
      def self.current
        @current ||= if ENV['GUARD_SESSION_ID']
          Cased::CLI::Session.find(ENV['GUARD_SESSION_ID'])
        end
      end

      def self.current?
        current.present?
      end

      class << self
        attr_writer :current
      end

      # @return [Cased::CLI::Authentication]
      attr_reader :authentication

      # Public: The CLI session ID
      # @example
      #   session.id #=> "guard_session_1oFqm5GBQYwhH8pfIpnS0A5QgFJ"
      # @return [String, nil]
      attr_reader :id

      # Public: The CLI session web URL
      # @example
      #   session.url #=> "https://api.cased.com/cli/programs/ruby/sessions/guard_session_1oFqm5GBQYwhH8pfIpnS0A5QgFJ"
      # @return [String, nil]
      attr_reader :url

      # Public: The CLI session API URL
      # @example
      #   session.api_url #=> "https://api.cased.com/cli/sessions/guard_session_1oFqm5GBQYwhH8pfIpnS0A5QgFJ"
      # @return [String, nil]
      attr_reader :api_url

      # Public: The CLI session record API URL
      # @example
      #   session.api_record_url #=> "https://api.cased.com/cli/sessions/guard_session_1oFqm5GBQYwhH8pfIpnS0A5QgFJ/record"
      # @return [String, nil]
      attr_reader :api_record_url

      # Public: The current state the CLI session is in
      # @example
      #   session.api_url #=> "approved"
      # @return [String, nil]
      attr_reader :state

      # Public: Command that invoked CLI session.
      # @example
      #   session.command #=> "/usr/local/bin/rails console"
      # @return [String]
      attr_accessor :command

      # Public: Additional user supplied metadata about the CLI session.
      # @example
      #   session.metadata #=> {"hostname" => "Mac.local"}
      # @return [Hash]
      attr_accessor :metadata

      # Public: The user supplied reason for the CLI session for taking place.
      # @example
      #   session.reason #=> "Investigating customer support ticket."
      # @return [String, nil]
      attr_accessor :reason

      # Public: The client's IP V4 or IP V6 address that initiated the CLI session.
      # @example
      #   session.reason #=> "1.1.1.1"
      # @return [String, nil]
      attr_reader :ip_address

      # Public: The Cased user that requested the CLI session.
      # @example
      #   session.requester #=> {"id" => "user_1oFqlROLNRGVLOXJSsHkJiVmylr"}
      # @return [Hash, nil]
      attr_reader :requester

      # Public: The Cased user that requested the CLI session.
      # @example
      #   session.responded_at #=> "2021-02-10 12:08:44 -0800"
      # @return [Time, nil]
      attr_reader :responded_at

      # Public: The Cased user that responded to the CLI session.
      # @example
      #   session.responder #=> {"id" => "user_1oFqlROLNRGVLOXJSsHkJiVmylr"}
      # @return [Hash, nil]
      attr_reader :responder

      # Public: The CLI application that the CLI session belongs to.
      # @example
      #   session.guard_application #=> {"id" => "guard_application_1oFqltbMqSEtJQKRCAYQNrQoXsS"}
      # @return [Hash, nil]
      attr_reader :guard_application

      def initialize(reason: nil, command: nil, metadata: {}, authentication: nil)
        @authentication = authentication || Cased::CLI::Authentication.new
        @reason = reason
        @command = command
        @metadata = metadata
        @requester = {}
        @responder = {}
        @guard_application = {}
      end

      def to_s
        command
      end

      def to_param
        id
      end

      def session=(session)
        @error = nil
        @id = session.fetch('id')
        @api_url = session.fetch('api_url')
        @api_record_url = session.fetch('api_record_url')
        @url = session.fetch('url')
        @state = session.fetch('state')
        @command = session.fetch('command')
        @metadata = session.fetch('metadata')
        @reason = session.fetch('reason')
        @ip_address = session.fetch('ip_address')
        @requester = session.fetch('requester')
        @responded_at = session['responded_at']
        @responder = session['responder'] || {}
        @guard_application = session.fetch('guard_application')
      end

      def requested?
        state == 'requested'
      end

      def approved?
        state == 'approved'
      end

      def denied?
        state == 'denied'
      end

      def canceled?
        state == 'canceled'
      end

      def timed_out?
        state == 'timed_out'
      end

      def refresh
        return false unless api_url

        response = Cased.clients.cli.get(api_url, user_token: authentication.token)
        self.session = response.body if response.success?
      end

      def error?
        !error.nil?
      end

      def success?
        id && !error?
      end

      def reason_required?
        error == :reason_required || guard_application.dig('settings', 'reason_required')
      end

      def unauthorized?
        error == :unauthorized
      end

      def record_output?
        guard_application.dig('settings', 'record_output') || false
      end

      def record
        return false unless recordable? && record_output?

        Cased::CLI::Log.log 'CLI session is now recording'

        # It's not guaranteed we're in an interactive session so lazy load
        # command unless specified.
        @command ||= [$PROGRAM_NAME, *ARGV].join(' ')

        recorder = Cased::CLI::Recorder.new(command.split(' '), env: {
          'GUARD_SESSION_ID' => id,
          'GUARD_APPLICATION_ID' => guard_application.fetch('id'),
          'GUARD_USER_TOKEN' => requester.fetch('id'),
        })
        recorder.start

        Cased.clients.cli.put(api_record_url,
          recording: recorder.writer.to_cast,
          user_token: authentication.token)

        Cased::CLI::Log.log 'CLI session recorded'
      end

      def create
        return false unless id.nil?

        response = Cased.clients.cli.post('cli/sessions',
          user_token: authentication.token,
          reason: reason,
          metadata: metadata,
          command: command)
        if response.success?
          self.session = response.body
        else
          case response.body['error']
          when 'reason_required'
            @error = :reason_required
          when 'unauthorized'
            @error = :unauthorized
          else
            @error = true
            return false
          end
        end

        response.success?
      end

      def cancel
        response = Cased.clients.cli.post("#{api_url}/cancel", user_token: authentication.token)
        self.session = response.body if response.success?

        canceled?
      end

      def cased_category
        :cli
      end

      def cased_id
        id
      end

      def cased_context(category: cased_category)
        {
          "#{category}_id".to_sym => cased_id,
          category.to_sym => to_s,
        }
      end

      def recordable?
        STDOUT.isatty
      end

      private

      attr_reader :error
    end
  end
end
