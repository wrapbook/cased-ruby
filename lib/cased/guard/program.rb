# frozen_string_literal: true

require 'pathname'

module Cased
  module Guard
    class Program
      def exists?
        !credentials.nil?
      end

      def credentials
        @credentials ||= begin
          credentials_path.read
        rescue Errno::ENOENT
          nil
        end
      end

      private

      def credentials_path
        directory.join('credentials')
      end

      def directory
        Pathname.new(File.expand_path('~/.cguard'))
      end
    end
  end
end
