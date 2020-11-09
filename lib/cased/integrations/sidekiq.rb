# frozen_string_literal: true

require 'sidekiq'
require 'cased/integrations/sidekiq/client_middleware'
require 'cased/integrations/sidekiq/server_middleware'

Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add Cased::Integrations::Sidekiq::ClientMiddleware
  end
end

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Cased::Integrations::Sidekiq::ServerMiddleware
  end
end
