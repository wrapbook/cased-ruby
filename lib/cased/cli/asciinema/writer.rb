# frozen_string_literal: true

require 'json'

module Cased
  module CLI
    # Spec: https://github.com/asciinema/asciinema/blob/develop/doc/asciicast-v2.md
    module Asciinema
      class Writer
        VERSION = 2

        attr_accessor :width
        attr_accessor :height
        attr_reader :stream
        attr_reader :started_at
        attr_reader :finished_at

        def initialize(command: [], width: 80, height: 24)
          @command = command
          @width = width
          @height = height
          @stream = []
          @started_at = Time.now
        end

        def <<(output)
          stream << [Time.now - started_at, 'o', output]
        end

        def time
          @started_at = Time.now
          ret = yield
          @finished_at = Time.now
          ret
        end

        def to_cast
          # In the event we didn't run the writer in a #time block, we should
          # set the finished time if it isn't set.
          @finished_at ||= Time.now

          File.new(header, stream).to_cast
        end

        def header
          {
            'version' => VERSION,
            'env' => {
              'SHELL' => ENV['SHELL'],
              'TERM' => ENV['TERM'],
            },
            'width' => width,
            'height' => height,
          }.tap do |h|
            if started_at
              h['timestamp'] = started_at.to_i
            end

            if started_at && finished_at
              h['duration'] = finished_at - started_at
            end
          end
        end
      end
    end
  end
end
