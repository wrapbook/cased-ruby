# frozen_string_literal: true

require 'cased/error'

module Cased
  module HTTP
    class Error < Cased::Error
      attr_reader :code

      def initialize(message = '', code = nil)
        super(message)
        @code = code
      end

      def self.from_response(response)
        new(response.body, response.status)
      end

      def self.class_from_response(response)
        klass = ERRORS[response.status]

        if klass
          klass
        elsif (300...400).cover?(response.status)
          RedirectionError
        elsif (400...500).cover?(response.status)
          ClientError
        elsif (500...600).cover?(response.status)
          ServerError
        else
          self
        end
      end

      # 3xx
      RedirectionError = Class.new(self)

      # 4xx
      ClientError = Class.new(self)

      # 400
      BadRequest = Class.new(ClientError)

      # 401
      Unauthorized = Class.new(ClientError)

      # 403
      Forbidden = Class.new(ClientError)

      # 404
      NotFound = Class.new(ClientError)

      # 406
      NotAcceptable = Class.new(ClientError)

      # 408
      RequestTimeout = Class.new(ClientError)

      # 409
      Conflict = Class.new(ClientError)

      # 422
      UnprocessableEntity = Class.new(ClientError)

      # 429
      TooManyRequests = Class.new(ClientError)

      # 5xx
      ServerError = Class.new(self)

      # 500
      InternalServerError = Class.new(ServerError)

      # 502
      BadGateway = Class.new(ServerError)

      # 503
      ServiceUnavailable = Class.new(ServerError)

      # 504
      GatewayTimeout = Class.new(ServerError)

      ERRORS = {
        400 => BadRequest,
        401 => Unauthorized,
        403 => Forbidden,
        404 => NotFound,
        406 => NotAcceptable,
        408 => RequestTimeout,
        422 => UnprocessableEntity,
        429 => TooManyRequests,
        500 => InternalServerError,
        502 => BadGateway,
        503 => ServiceUnavailable,
        504 => GatewayTimeout,
      }.freeze
    end
  end
end
