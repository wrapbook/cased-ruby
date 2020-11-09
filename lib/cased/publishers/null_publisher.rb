# frozen_string_literal: true

require 'cased/publishers/base'

module Cased
  module Publishers
    class NullPublisher < Base
      def publish(_event); end
    end
  end
end
