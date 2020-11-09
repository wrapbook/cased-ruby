# frozen_string_literal: true

require 'test_helper'

module Cased
  module Sensitive
    class StringTest < Minitest::Test
      def test_sensitive_string_can_find_all_matches
        string = Cased::Sensitive::String.new('Hello @username and @username')

        expected_matches = [
          { begin: 6, end: 15 }, # first @username
          { begin: 20, end: 29 }, # second @username
        ]

        string.matches(/@\w+/).each_with_index do |match, index|
          expected_match = expected_matches[index]

          assert_equal expected_match[:begin], match.begin(0)
          assert_equal expected_match[:end], match.end(0)
        end
      end
    end
  end
end
