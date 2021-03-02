# frozen_string_literal: true

module Cased
  module CLI
    class Identity
      def initialize
        @timeout = 30
      end

      def identify
        response = Cased.clients.cli.post('cli/applications/users/identify')
        case response.status
        when 201 # Created
          url = response.body.fetch('url')
          Cased::CLI::Log.log "To login, please visit:"
          puts url
          poll(response.body['api_url'])
        when 401 # Unauthorized
          false
        end
      end

      def poll(poll_url)
        count = 0
        user_id = nil

        while user_id.nil?
          count += 1
          response = Cased.clients.cli.get(poll_url)
          user_id = response.body.dig('user', 'id')
          sleep 1 if user_id.nil?
        end

        user_id
      end
    end
  end
end
