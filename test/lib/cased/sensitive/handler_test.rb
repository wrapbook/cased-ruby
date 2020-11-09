# frozen_string_literal: true

require 'test_helper'

module Cased
  module Sensitive
    class HandlerTest < Minitest::Test
      def test_handles_regex
        handler = Cased::Sensitive::Handler.new(:username, /@\w+/)
        matches = handler.call({}, :action, 'Hello @username and @username')

        expected_matches = [
          Cased::Sensitive::Range.new(label: :username, key: :action, begin_offset: 6, end_offset: 15),
          Cased::Sensitive::Range.new(label: :username, key: :action, begin_offset: 20, end_offset: 29),
        ]

        assert_equal expected_matches, matches
      end

      def test_handles_invalid_handler
        exception = assert_raises(ArgumentError) do
          Cased::Sensitive::Handler.new(:username, String)
        end

        assert_equal 'expected Cased::Sensitive::String to be a Regexp or Proc', exception.message
      end
    end
  end
end
