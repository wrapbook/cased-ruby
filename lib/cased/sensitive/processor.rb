# frozen_string_literal: true

require 'cased/sensitive/string'

module Cased
  module Sensitive
    class Processor
      def self.process(audit_event, handlers = nil)
        handlers ||= Cased::Sensitive::Handler.handlers
        processor = new(audit_event, handlers)
        processor.process
        processor
      end

      def self.process!(audit_event, handlers = nil)
        processor = process(audit_event, handlers)
        return unless processor.sensitive?

        audit_event[:'.cased'] = {
          pii: processor.to_h,
        }
      end

      attr_reader :audit_event
      attr_reader :handlers

      def initialize(audit_event, handlers)
        @audit_event = audit_event.dup.freeze
        @ranges = []
        @handlers = handlers
      end

      def process
        return true if defined?(@processed)

        walk(audit_event)
        @processed = true
      end

      def ranges
        @ranges.flatten
      end

      def sensitive?
        process && ranges.any?
      end

      def to_h
        results = {}
        ranges.each do |range|
          results[range.key] ||= []
          results[range.key] << range.to_h
        end
        results
      end

      private

      def walk(hash)
        hash.each_with_json_path do |path, value|
          case value
          when Cased::Sensitive::String
            @ranges << value.range(key: path)
          when ::String
            process_handlers(audit_event, path, value)
          end
        end
      end

      def process_handlers(audit_event, path, value)
        handlers.each do |handler|
          ranges = handler.call(audit_event, path, value)
          @ranges << ranges unless ranges.nil? || ranges.empty?
        end
      end
    end
  end
end
