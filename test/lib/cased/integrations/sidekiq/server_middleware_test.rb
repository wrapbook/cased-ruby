# frozen_string_literal: true

require 'test_helper'

module Cased
  module Integrations
    module Sidekiq
      class ServerMiddlewareTest < Cased::Test
        def test_sets_context_for_duration_of_job
          middleware = Cased::Integrations::Sidekiq::ServerMiddleware.new
          context = {
            'cased_context' => {
              'location' => '127.0.0.1',
            },
          }

          assert_nil Cased.context['location']
          middleware.call(nil, context, nil) do
            assert_equal '127.0.0.1', Cased.context['location']
          end
          assert_nil Cased.context['location']
        end

        def test_sets_job_class_in_context
          middleware = Cased::Integrations::Sidekiq::ServerMiddleware.new
          context = {
            'cased_context' => {
              'location' => '127.0.0.1',
            },
            'class' => 'ClassName',
          }

          assert_empty Cased.context.context
          middleware.call(nil, context, nil) do
            expected_context = {
              'location' => '127.0.0.1',
              'job_class' => 'ClassName',
            }

            assert_equal expected_context, Cased.context.context
          end
          assert_empty Cased.context.context
        end

        def test_processes_empty_cased_context
          middleware = Cased::Integrations::Sidekiq::ServerMiddleware.new
          context = {
            'cased_context' => nil,
            'class' => 'ClassName',
          }

          assert_empty Cased.context.context
          middleware.call(nil, context, nil) do
            expected_context = {
              'job_class' => 'ClassName',
            }

            assert_equal expected_context, Cased.context.context
          end
          assert_empty Cased.context.context
        end

        def test_processes_empty_context
          middleware = Cased::Integrations::Sidekiq::ServerMiddleware.new
          context = {
            'class' => 'ClassName',
          }

          assert_empty Cased.context.context
          middleware.call(nil, context, nil) do
            expected_context = {
              'job_class' => 'ClassName',
            }

            assert_equal expected_context, Cased.context.context
          end
          assert_empty Cased.context.context
        end
      end
    end
  end
end
