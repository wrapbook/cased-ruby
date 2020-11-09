# frozen_string_literal: true

require 'cased/publishers/error'

module Cased
  module Publishers
    class Base
      def publish(_audit_event)
        raise "#{self.class} must implement the #{self.class}#publish method"
      end

      def ==(other)
        self.class == other.class
      end
    end
  end
end
