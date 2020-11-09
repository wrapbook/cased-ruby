# frozen_string_literal: true

require 'cased/sensitive/range'

module Cased
  module Sensitive
    class String < String
      attr_reader :label
      attr_reader :string

      def initialize(string, label: nil)
        super(string)
        @label = label
      end

      def range(key:)
        Cased::Sensitive::Range.new(
          label: label,
          key: key,
          begin_offset: 0,
          end_offset: length,
        )
      end

      def matches(regex)
        offset = 0
        matches = []

        while (result = match(regex, offset))
          matches.push(result)
          offset = result.end(0)
        end

        matches
      end

      def ==(other)
        super(other) &&
          @label == other.label
      end
    end
  end
end
