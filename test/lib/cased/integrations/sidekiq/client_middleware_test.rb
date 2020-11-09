# frozen_string_literal: true

require 'test_helper'

module Cased
  module Integrations
    module Sidekiq
      class ClientMiddlewareTest < Cased::Test
        def test_adds_context_to_job_on_call
          actual_context = {}
          Cased.context.merge(location: '127.0.0.1')

          middleware = Cased::Integrations::Sidekiq::ClientMiddleware.new
          middleware.call(nil, actual_context, nil, nil) do
            # need block for call
          end

          expected_context = {
            'cased_context' => {
              location: '127.0.0.1',
            },
          }

          assert_equal expected_context, actual_context
        end
      end
    end
  end
end
