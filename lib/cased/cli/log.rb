# frozen_string_literal: true

module Cased
  module CLI
    module Log
      CLEAR   = "\e[0m"
      YELLOW  = "\e[33m"
      BOLD    = "\e[1m"

      def self.string(text)
        [color('[cased]', YELLOW, true), text].join(' ')
      end

      def self.log(text)
        puts string(text)
      ensure
        $stdout.flush
      end

      def self.color(text, color, bold = false) # rubocop:disable Style/OptionalBooleanParameter
        color = self.class.const_get(color.upcase) if color.is_a?(Symbol)
        bold  = bold ? BOLD : ''
        "#{bold}#{color}#{text}#{CLEAR}"
      end
    end
  end
end
