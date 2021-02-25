require 'subprocess'

module Cased
  module CLI
    class Record
      KEY = 'CASED_CLI_RECORDING'

      attr_reader :command
      attr_reader :events
      attr_reader :started_at
      attr_reader :width
      attr_reader :height
      attr_reader :env
      attr_reader :options

      def self.recording?
        ENV[KEY] == '1'
      end

      def initialize(command)
        @command = command
        @events = []
        @width = 252
        @height = 71

        @env = ENV.to_h.dup
        @env[KEY] = '1'
        @options = {
          stdout: Subprocess::PIPE,
          # stderr: Subprocess::PIPE,
          env: env,
        }
      end

      def start
        @started_at = Time.now
        Subprocess.check_call(command, options) do |t|
          t.communicate do |stdout, stderr|
            STDOUT.write(stdout)

            events << [Time.now, 'o', stdout.gsub("\n", "\r\n")]
          end
        end
      end

      def to_cast
        header = {
          version: 2,
          timestamp: started_at.to_i,
          env: {
            SHELL: ENV['SHELL'],
            TERM: ENV['TERM'],
          },
          width: width,
          height: height,
          duration: Time.now-started_at,
          command: command.join(' '),
        }
        builder = []

        builder << header.to_json
        events.each do |timestamp, type, data|
          builder << [timestamp-started_at, type, data].to_json
        end

        builder.join("\n")
      end
    end
  end
end
