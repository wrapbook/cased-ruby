# frozen_string_literal: true

require 'subprocess'

module Cased
  module CLI
    class Recorder
      KEY = 'CASED_CLI_RECORDING'
      TRUE = '1'

      attr_reader :command
      attr_reader :events
      attr_reader :started_at
      attr_reader :width
      attr_reader :height
      attr_reader :options
      attr_accessor :writer

      # @return [Boolean] if CLI session is being recorded.
      def self.recording?
        ENV[KEY] == TRUE
      end

      def initialize(command, env: {})
        @command = command
        @events = []
        @width = Subprocess.check_output(%w[tput cols]).strip.to_i
        @height = Subprocess.check_output(%w[tput lines]).strip.to_i

        subprocess_env = ENV.to_h.dup
        subprocess_env[KEY] = TRUE
        subprocess_env.merge!(env)
        @writer = Cased::CLI::Asciinema::Writer.new(
          command: command,
          width: width,
          height: height,
        )

        @options = {
          stdout: Subprocess::PIPE,
          env: subprocess_env,
        }
      end

      def start
        writer.time do
          Subprocess.check_call(command, options) do |t|
            t.communicate do |stdout, _stderr|
              STDOUT.write(stdout)

              writer << stdout.gsub("\n", "\r\n")
            end
          end
        end
      end
    end
  end
end
