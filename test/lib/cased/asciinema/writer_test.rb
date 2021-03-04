# frozen_string_literal: true

require 'active_support/testing/assertions'

module Cased
  module CLI
    module Asciinema
      class WriterTest < Cased::Test
        include ActiveSupport::Testing::Assertions

        def test_default_writer
          writer = Cased::CLI::Asciinema::Writer.new(command: ['irb'])

          assert_equal ['irb'], writer.command
          assert_equal 80, writer.width
          assert_equal 24, writer.height
          assert_empty writer.stream
        end

        def test_write_data
          writer = Cased::CLI::Asciinema::Writer.new(command: ['irb'])
          writer << 'hello'

          assert_equal 1, writer.stream.length
          t, type, data = writer.stream.pop

          assert_in_delta 1.0, t, 1
          assert_equal 'o', type
          assert_equal 'hello', data
        end

        def test_write_data_in_block
          writer = Cased::CLI::Asciinema::Writer.new(command: ['irb'])
          value = writer.time do
            writer << 'hello'
            'finish'
          end

          assert_equal 'finish', value
        end

        def test_to_cast
          writer = Cased::CLI::Asciinema::Writer.new(command: ['irb'])
          writer.time do
            writer << 'hello'
          end

          assert_includes writer.to_cast, 'hello"]'
        end
      end
    end
  end
end
