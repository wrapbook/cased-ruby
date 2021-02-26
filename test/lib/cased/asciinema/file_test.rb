# frozen_string_literal: true

require 'active_support/testing/assertions'

module Cased
  module CLI
    module Asciinema
      class FileTest < Cased::Test
        include ActiveSupport::Testing::Assertions

        def test_required_header
          header = {
            'version' => 2,
            'width' => 80,
            'height' => 24,
          }
          stream = [
            [0.123456, 'o', 'data'],
          ]
          file = Cased::CLI::Asciinema::File.new(header, stream)

          assert_equal 2, file.version
          assert_equal 80, file.width
          assert_equal 24, file.height
        end

        def test_timestamp_as_integer
          header = {
            'version' => 2,
            'width' => 80,
            'height' => 24,
            'timestamp' => 1_614_314_615,
          }
          stream = [
            [0.123456, 'o', 'data'],
          ]
          file = Cased::CLI::Asciinema::File.new(header, stream)

          assert_equal Time.at(1_614_314_615), file.timestamp
        end

        def test_timestamp_as_time
          header = {
            'version' => 2,
            'width' => 80,
            'height' => 24,
            'timestamp' => Time.at(1_614_314_615),
          }
          stream = [
            [0.123456, 'o', 'data'],
          ]
          file = Cased::CLI::Asciinema::File.new(header, stream)

          assert_equal Time.at(1_614_314_615), file.timestamp
        end

        def test_blank_timestamp
          header = {
            'version' => 2,
            'width' => 80,
            'height' => 24,
          }
          stream = [
            [0.123456, 'o', 'data'],
          ]
          file = Cased::CLI::Asciinema::File.new(header, stream)

          assert_nil file.timestamp
        end

        def test_invalid_timestamp
          header = {
            'version' => 2,
            'width' => 80,
            'height' => 24,
            'timestamp' => true,
          }
          stream = [
            [0.123456, 'o', 'data'],
          ]
          exception = assert_raises(ArgumentError) do
            Cased::CLI::Asciinema::File.new(header, stream)
          end

          assert_equal 'unexpected timestamp format TrueClass, expected Integer, Time, or nil', exception.message
        end

        def test_duration
          header = {
            'version' => 2,
            'width' => 80,
            'height' => 24,
            'duration' => 0.123456,
          }
          stream = [
            [0.123456, 'o', 'data'],
          ]
          file = Cased::CLI::Asciinema::File.new(header, stream)

          assert_equal 0.123456, file.duration
        end

        def test_blank_duration
          header = {
            'version' => 2,
            'width' => 80,
            'height' => 24,
          }
          stream = [
            [0.123456, 'o', 'data'],
          ]
          file = Cased::CLI::Asciinema::File.new(header, stream)

          assert_nil file.duration
        end

        def test_invalid_duration
          header = {
            'version' => 2,
            'width' => 80,
            'height' => 24,
            'duration' => 1,
          }
          stream = [
            [0.123456, 'o', 'data'],
          ]
          exception = assert_raises(ArgumentError) do
            Cased::CLI::Asciinema::File.new(header, stream)
          end

          assert_equal 'unexpected duration format Integer, expected Float or nil', exception.message
        end

        def test_idle_time_limit
          idle_time_limit = -1
          header = {
            'version' => 2,
            'width' => 80,
            'height' => 24,
            'idle_time_limit' => idle_time_limit,
          }
          stream = [
            [0.123456, 'o', 'data'],
          ]
          file = Cased::CLI::Asciinema::File.new(header, stream)

          assert_equal idle_time_limit, file.idle_time_limit
        end

        def test_blank_idle_time_limit
          header = {
            'version' => 2,
            'width' => 80,
            'height' => 24,
          }
          stream = [
            [0.123456, 'o', 'data'],
          ]
          file = Cased::CLI::Asciinema::File.new(header, stream)

          assert_nil file.idle_time_limit
        end

        def test_invalid_idle_time_limit
          header = {
            'version' => 2,
            'width' => 80,
            'height' => 24,
            'idle_time_limit' => true,
          }
          stream = [
            [0.123456, 'o', 'data'],
          ]
          exception = assert_raises(ArgumentError) do
            Cased::CLI::Asciinema::File.new(header, stream)
          end

          assert_equal 'unexpected idle_time_limit format TrueClass, expected Integer, Float, or nil', exception.message
        end

        def test_command
          header = {
            'version' => 2,
            'width' => 80,
            'height' => 24,
            'command' => 'irb',
          }
          stream = [
            [0.123456, 'o', 'data'],
          ]
          file = Cased::CLI::Asciinema::File.new(header, stream)

          assert_equal 'irb', file.command
        end

        def test_title
          header = {
            'version' => 2,
            'width' => 80,
            'height' => 24,
            'title' => 'irb shell',
          }
          stream = [
            [0.123456, 'o', 'data'],
          ]
          file = Cased::CLI::Asciinema::File.new(header, stream)

          assert_equal 'irb shell', file.title
        end

        def test_env
          env = {
            'TERM' => 'xterm-256color',
            'SHELL' => 'sh',
          }
          header = {
            'version' => 2,
            'width' => 80,
            'height' => 24,
            'env' => env,
          }
          stream = [
            [0.123456, 'o', 'data'],
          ]
          file = Cased::CLI::Asciinema::File.new(header, stream)

          assert_equal env, file.env
        end

        def test_theme
          theme = {
            'fg' => '#d0d0d0',
            'bg' => '#212121',
            'palette' => '#151515:#ac4142:#7e8e50:#e5b567:#6c99bb:#9f4e85:#7dd6cf:#d0d0d0:#505050:#ac4142:#7e8e50:#e5b567:#6c99bb:#9f4e85:#7dd6cf:#f5f5f5',
          }
          header = {
            'version' => 2,
            'width' => 80,
            'height' => 24,
            'theme' => theme,
          }
          stream = [
            [0.123456, 'o', 'data'],
          ]
          file = Cased::CLI::Asciinema::File.new(header, stream)

          assert_equal theme, file.theme
        end

        def test_stream
          header = {
            'version' => 2,
            'width' => 80,
            'height' => 24,
          }
          stream = [
            [0.123456, 'o', 'data'],
          ]
          file = Cased::CLI::Asciinema::File.new(header, stream)

          assert_equal stream, file.stream
        end

        def test_to_s
          header = {
            'version' => 2,
            'width' => 80,
            'height' => 24,
          }
          stream = [
            [3.793686, 'o', 'U'],
            [3.883639, 'o', 's'],
            [4.035233, 'o', 'e'],
            [4.153766, 'o', 'r'],
            [4.230043, 'o', '.'],
            [4.348715, 'o', 'f'],
            [4.469897, 'o', 'i'],
            [4.513506, 'o', 'r'],
            [4.633844, 'o', 's'],
            [4.755115, 'o', 't'],
          ]
          file = Cased::CLI::Asciinema::File.new(header, stream)

          assert_equal 'User.first', file.to_s
        end

        def test_to_cast
          header = {
            'version' => 2,
            'width' => 80,
            'height' => 24,
            'timestamp' => 1_614_314_615,
            'duration' => 0.123456,
            'idle_time_limit' => 1,
            'command' => 'irb',
            'title' => 'irb shell',
            'env' => {
              'TERM' => 'xterm-256color',
              'SHELL' => 'sh',
            },
            'theme' => {
              'fg' => '#d0d0d0',
              'bg' => '#212121',
              'palette' => '#151515:#ac4142:#7e8e50:#e5b567:#6c99bb:#9f4e85:#7dd6cf:#d0d0d0:#505050:#ac4142:#7e8e50:#e5b567:#6c99bb:#9f4e85:#7dd6cf:#f5f5f5',
            },
          }
          stream = [
            [3.793686, 'o', 'U'],
            [3.883639, 'o', 's'],
            [4.035233, 'o', 'e'],
            [4.153766, 'o', 'r'],
            [4.230043, 'o', '.'],
            [4.348715, 'o', 'f'],
            [4.469897, 'o', 'i'],
            [4.513506, 'o', 'r'],
            [4.633844, 'o', 's'],
            [4.755115, 'o', 't'],
          ]
          file = Cased::CLI::Asciinema::File.new(header, stream)

          expected_cast = <<~CAST.strip
            {"version":2,"width":80,"height":24,"timestamp":1614314615,"duration":0.123456,"idle_time_limit":1,"command":"irb","title":"irb shell","env":{"TERM":"xterm-256color","SHELL":"sh"},"theme":{"fg":"#d0d0d0","bg":"#212121","palette":"#151515:#ac4142:#7e8e50:#e5b567:#6c99bb:#9f4e85:#7dd6cf:#d0d0d0:#505050:#ac4142:#7e8e50:#e5b567:#6c99bb:#9f4e85:#7dd6cf:#f5f5f5"}}
            [3.793686,"o","U"]
            [3.883639,"o","s"]
            [4.035233,"o","e"]
            [4.153766,"o","r"]
            [4.230043,"o","."]
            [4.348715,"o","f"]
            [4.469897,"o","i"]
            [4.513506,"o","r"]
            [4.633844,"o","s"]
            [4.755115,"o","t"]
          CAST

          assert_equal expected_cast, file.to_cast
        end
      end
    end
  end
end
