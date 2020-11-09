# frozen_string_literal: true

module Cased
  module Publishers
    class BaseTest < Cased::Test
      def test_raises_error_on_publish
        base = Cased::Publishers::Base.new

        exception = assert_raises(StandardError) do
          base.publish(action: 'user.login')
        end

        assert_equal 'Cased::Publishers::Base must implement the Cased::Publishers::Base#publish method', exception.message
      end
    end
  end
end
