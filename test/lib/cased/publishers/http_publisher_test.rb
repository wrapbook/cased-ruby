# frozen_string_literal: true

module Cased
  module Publishers
    class HTTPPublisherTest < Cased::Test
      def test_publish_audit_event
        original_publish_key = ENV['CASED_PUBLISH_KEY']
        ENV['CASED_PUBLISH_KEY'] = 'test'

        stub_request(:post, 'https://publish.cased.com/')
          .with(
            body: '{"action":"user.login"}',
            headers: {
              'Content-Type' => 'application/json',
            },
          )
          .to_return(status: 200)

        http = Cased::Publishers::HTTPPublisher.new

        http.publish(action: 'user.login')
      ensure
        ENV['CASED_PUBLISH_KEY'] = original_publish_key
      end
    end
  end
end
