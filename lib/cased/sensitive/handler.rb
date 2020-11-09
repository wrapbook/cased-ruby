# frozen_string_literal: true

module Cased
  module Sensitive
    class Handler
      def self.handlers
        @handlers ||= []
      end

      class << self
        attr_writer :handlers
      end

      def self.register(label, handler)
        handlers << Handler.new(label, handler)
      end

      attr_reader :label

      def initialize(label, handler)
        @label = label.to_sym
        @handler = prepare_handler(handler)
      end

      def call(audit_event, key, value)
        @handler.call(audit_event, key.to_sym, value)
      end

      private

      def prepare_handler(handler)
        case handler
        when Regexp
          proc do |_audit_event, key, value|
            string = Cased::Sensitive::String.new(value)
            string.matches(handler).collect do |match|
              begin_offset = match.begin(0)
              end_offset = match.end(0)

              Cased::Sensitive::Range.new(
                label: label,
                key: key,
                begin_offset: begin_offset,
                end_offset: end_offset,
              )
            end
          end
        else
          raise ArgumentError, "expected #{handler} to be a Regexp or Proc"
        end
      end
    end
  end
end
