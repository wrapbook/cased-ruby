# frozen_string_literal: true

module Cased
  module Sensitive
    class Range
      # Public: The human label describing what sensitive information was
      # label. Username, email, date of birth, etc.
      attr_reader :label

      # Public: The JSON key.
      attr_reader :key

      # Public: This is the identifier that groups sensitive ranges together.
      # This could be an identifier to an individual for example.
      attr_reader :identifier

      # Public: The beginning offset of the sensitive value in the original value.
      attr_reader :begin_offset

      # Public: The end offset of the sensitive value in the original value.
      attr_reader :end_offset

      def initialize(key:, begin_offset:, end_offset:, identifier: nil, label: nil)
        raise ArgumentError, 'missing key' if key.nil?
        raise ArgumentError, 'missing begin_offset' if begin_offset.nil?
        raise ArgumentError, 'missing end_offset' if end_offset.nil?

        @label = label
        @key = key
        @identifier = identifier
        @begin_offset = begin_offset
        @end_offset = end_offset
      end

      def ==(other)
        @begin_offset == other.begin_offset &&
          @end_offset == other.end_offset &&
          @label == other.label &&
          @key == other.key &&
          @identifier == other.identifier
      end

      def to_h
        {
          begin: @begin_offset,
          end: @end_offset,
        }.tap do |hash|
          hash[:label] = label if label
          hash[:identifier] = identifier if identifier
        end
      end
    end
  end
end
