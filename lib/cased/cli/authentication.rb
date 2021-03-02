# frozen_string_literal: true

require 'pathname'

module Cased
  module CLI
    class Authentication
      attr_reader :directory
      attr_reader :credentials_path
      attr_writer :token

      def initialize
        @token = Cased.config.guard_user_token
        @directory = Pathname.new(File.expand_path('~/.cguard'))
        @credentials_path = @directory.join('credentials')
      end

      def exists?
        !token.nil?
      end

      def token
        @token ||= begin
          credentials_path.read
        rescue Errno::ENOENT
          nil
        end
      end
    end
  end
end
