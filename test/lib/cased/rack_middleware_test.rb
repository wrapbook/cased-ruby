# frozen_string_literal: true

require 'test_helper'
require 'rack/mock'

module Cased
  class RackMiddlewareTest < Cased::Test
    def test_middleware_clears_context_after_request
      Cased.context.merge(action: 'user.login')

      app = ->(env) { [200, env, 'cased'] }
      middleware = Cased::RackMiddleware.new(app)
      request = Rack::MockRequest.env_for('https://cased.com')

      middleware.call(request)

      assert_empty Cased::Context.current.context
    end
  end
end
