# frozen_string_literal: true

require 'active_support/testing/assertions'

module Cased
  module CLI
    class IdentityTest < Cased::Test
      include ActiveSupport::Testing::Assertions

      def test_identify
        stub_request(:post, 'https://api.cased.com/cli/applications/users/identify')
          .to_return(
            status: 201,
            body: {
              url: 'https://app.cased.com/g1234',
              api_url: 'https://api.cased.com/cli/applications/users/identify/request_id',
            }.to_json,
            headers: {
              'Content-Type' => 'application/json',
            },
          )

        stub_request(:get, 'https://api.cased.com/cli/applications/users/identify/request_id')
          .to_return(
            status: 200,
            body: {
              user: {
                id: 'user_1234',
              },
            }.to_json,
            headers: {
              'Content-Type' => 'application/json',
            },
          )

        identify = Cased::CLI::Identity.new

        assert_equal 'user_1234', identify.identify
      end

      def test_identify_is_unauthorized
        stub_request(:post, 'https://api.cased.com/cli/applications/users/identify')
          .to_return(
            status: 401,
            body: {
              url: 'https://app.cased.com/g1234',
              api_url: 'https://api.cased.com/cli/applications/users/identify/request_id',
            }.to_json,
            headers: {
              'Content-Type' => 'application/json',
            },
          )

        identify = Cased::CLI::Identity.new

        assert_equal false, identify.identify
      end
    end
  end
end
