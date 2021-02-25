# frozen_string_literal: true

require 'jwt'

module Cased
  module CLI
    module Sessions
      class Intent
        attr_reader :reason_required

        def initialize(secret_key, reason_required: false)
          @secret_key = secret_key
          @reason_required = reason_required
        end

        def reason_required?
          reason_required
        end

        def generate
          JWT.encode(payload, secret_key, 'HS256')
        end

        def payload
          {
            reason_required: reason_required?,

            # Issuer
            iss: 'Cased',

            # Issued at
            iat: Time.now.to_i,

            # Expires
            exp: Time.now.to_i + 60_000,
          }
        end

        def to_s
          generate
        end

        private

        attr_reader :secret_key
      end
    end
  end
end
