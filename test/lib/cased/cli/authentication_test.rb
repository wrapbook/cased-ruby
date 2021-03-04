# frozen_string_literal: true

require 'active_support/testing/assertions'

module Cased
  module CLI
    class AuthenticationTest < Cased::Test
      include ActiveSupport::Testing::Assertions

      def test_token
        authentication = Cased::CLI::Authentication.new(token: 'test_token')

        assert_equal 'test_token', authentication.token
      end

      def test_token_exists
        authentication = Cased::CLI::Authentication.new(token: 'test_token')

        assert_predicate authentication, :exists?
      end

      def test_token_exists_from_credentials
        Pathname.any_instance.stubs(:read).returns('synced-token')

        authentication = Cased::CLI::Authentication.new

        assert_equal 'synced-token', authentication.token
      end

      def test_token_returns_nil_if_file_doesnt_exist
        Pathname.any_instance.stubs(:read).raises(Errno::ENOENT)

        authentication = Cased::CLI::Authentication.new

        assert_nil authentication.token
      end

      def test_token_from_configuration
        old_guard_user_token = Cased.config.guard_user_token
        Cased.config.guard_user_token = 'test_token_from_configuration'

        authentication = Cased::CLI::Authentication.new
        assert_equal 'test_token_from_configuration', authentication.token
      ensure
        Cased.config.guard_user_token = old_guard_user_token
      end
    end
  end
end
