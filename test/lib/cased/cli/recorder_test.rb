# frozen_string_literal: true

require 'active_support/testing/assertions'

module Cased
  module CLI
    class RecorderTest < Cased::Test
      include ActiveSupport::Testing::Assertions

      def test_default_recorder
        Subprocess.stubs(:check_output).with(%w[tput cols]).returns('80')
        Subprocess.stubs(:check_output).with(%w[tput lines]).returns('24')
        recorder = Cased::CLI::Recorder.new(['irb'])

        assert_equal ['irb'], recorder.command
        assert_equal 80, recorder.width
        assert_equal 24, recorder.height
        assert recorder.options[:env].key?(Cased::CLI::Recorder::KEY)
      end

      def test_recording
        old_value = ENV[Cased::CLI::Recorder::KEY]

        refute_predicate Cased::CLI::Recorder, :recording?
        ENV[Cased::CLI::Recorder::KEY] = Cased::CLI::Recorder::TRUE
        assert_predicate Cased::CLI::Recorder, :recording?
      ensure
        ENV[Cased::CLI::Recorder::KEY] = old_value
      end

      def test_start
        Subprocess.stubs(:check_call).returns('80')
        recorder = Cased::CLI::Recorder.new(['irb'])

        assert_nil recorder.writer.finished_at
        recorder.start

        refute_nil recorder.writer.finished_at
      end
    end
  end
end
