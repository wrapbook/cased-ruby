# frozen_string_literal: true

require 'json'

module Cased
  module CLI
    # Spec: https://github.com/asciinema/asciinema/blob/develop/doc/asciicast-v2.md
    module Asciinema
      class File
        OUT = 'o'
        IN = 'i'

        def self.from_writer(writer)
          new(writer.header, writer.stream)
        end

        def self.from_cast(cast)
          return if cast.blank?

          stream = cast.split("\n").collect do |data|
            JSON.parse(data)
          end
          header = stream.shift
          return unless header.is_a?(Hash)

          new(header, stream)
        rescue JSON::ParserError
          nil
        end

        # Required
        attr_reader :header, :version, :width, :height, :stream

        # Optional
        attr_reader :timestamp, :duration, :idle_time_limit, :command, :title, :env, :theme

        def initialize(header, stream)
          @header = header
          @version = header.fetch('version')
          @width = header.fetch('width')
          @height = header.fetch('height')
          self.timestamp = header['timestamp']
          self.duration = header['duration']
          self.idle_time_limit = header['idle_time_limit']
          @command = header['command']
          @title = header['title']
          @env = header.fetch('env', {})
          @theme = header['theme']
          @stream = stream
        end

        def timestamp=(new_timestamp)
          @timestamp = case new_timestamp
          when Integer
            Time.at(new_timestamp)
          when Time, NilClass
            new_timestamp
          else
            raise ArgumentError, "unexpected timestamp format #{new_timestamp.class}, expected Integer, Time, or nil"
          end
        end

        def duration=(new_duration)
          @duration = case new_duration
          when Float, NilClass
            new_duration
          else
            raise ArgumentError, "unexpected duration format #{new_duration.class}, expected Float or nil"
          end
        end

        def idle_time_limit=(new_idle_time_limit)
          @idle_time_limit = case new_idle_time_limit
          when Numeric, NilClass
            new_idle_time_limit
          else
            raise ArgumentError, "unexpected idle_time_limit format #{new_idle_time_limit.class}, expected Integer, Float, or nil"
          end
        end

        def to_cast
          builder = []
          builder << JSON.dump(header)
          stream.each do |duration, type, data|
            builder << JSON.dump([duration, type, data])
          end
          builder.join("\n")
        end

        def to_s
          str = []
          stream.each do |_timestamp, type, data|
            next unless type == OUT

            str << data
          end

          str.join
        end
      end
    end
  end
end
