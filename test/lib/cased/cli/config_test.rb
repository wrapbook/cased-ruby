# frozen_string_literal: true

require 'active_support/testing/assertions'

module Cased
  module CLI
    class ConfigTest < Cased::Test
      include ActiveSupport::Testing::Assertions

      def test_default_metadata
        config = Cased::CLI::Config.new
        metadata = {}

        assert_equal metadata, config.metadata
      end

      def test_configure_metadata
        config = Cased::CLI::Config.new
        metadata = {
          heroku_application: 'my app',
        }
        config.metadata = metadata

        assert_equal metadata, config.metadata
      end
    end
  end
end
