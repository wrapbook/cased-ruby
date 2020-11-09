# frozen_string_literal: true

module Cased
  module Integrations
    module Sidekiq
      class ClientMiddleware
        def call(_worker_class, job, _queue, _redis_pool)
          job['cased_context'] = Cased.context.context
          yield
        end
      end
    end
  end
end
