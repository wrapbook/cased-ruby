# frozen_string_literal: true

module Cased
  module Integrations
    module Sidekiq
      class ServerMiddleware
        def call(_worker, job, _queue)
          context = (job['cased_context'] || {})
          context['job_class'] = job['class']

          Cased::Context.current = context

          yield
        ensure
          Cased::Context.clear!
        end
      end
    end
  end
end
