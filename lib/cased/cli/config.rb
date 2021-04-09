# frozen_string_literal: true

module Cased
  module CLI
    class Config
      # @example
      #   Cased.configure do |config|
      #     config.cli.metadata = {
      #       rails_env: ENV['RAILS_ENV'],
      #       heroku_application: ENV['HEROKU_APP_NAME'],
      #       git_commit: ENV['GIT_COMMIT'],
      #     }
      #   end
      attr_accessor :metadata

      def initialize
        @metadata = {}
      end
    end
  end
end
