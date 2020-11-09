# frozen_string_literal: true

module Cased
  class RackMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      @app.call(env)
    ensure
      Cased::Context.clear!
    end
  end
end
