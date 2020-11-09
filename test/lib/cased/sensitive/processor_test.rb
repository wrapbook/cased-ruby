# frozen_string_literal: true

require 'test_helper'

module Cased
  module Sensitive
    class ProcessorTest < Minitest::Test
      def test_processes_audit_event_with_explicit_handlers
        handler = Cased::Sensitive::Handler.new(:username, /@\w+/)
        result = Cased::Sensitive::Processor.process({ action: 'Hello @username' }, [handler])

        expected_result = {
          '.action': [
            {
              label: :username,
              begin: 6,
              end: 15,
            },
          ],
        }

        assert_equal expected_result, result.to_h
      end

      def test_processes_audit_event_with_global_handlers
        old_handlers = Cased::Sensitive::Handler.handlers
        Cased::Sensitive::Handler.handlers = []
        Cased::Sensitive::Handler.register(:phone_number, /\d{3}\-\d{3}\-\d{4}/)
        result = Cased::Sensitive::Processor.process(action: 'Hello 111-222-3333')

        expected_result = {
          '.action': [
            {
              label: :phone_number,
              begin: 6,
              end: 18,
            },
          ],
        }

        assert_equal expected_result, result.to_h
      ensure
        Cased::Sensitive::Handler.handlers = old_handlers
      end

      def test_processes_nested_audit_event_with_global_handlers
        old_handlers = Cased::Sensitive::Handler.handlers
        Cased::Sensitive::Handler.handlers = []
        Cased::Sensitive::Handler.register(:phone_number, /\d{3}\-\d{3}\-\d{4}/)
        result = Cased::Sensitive::Processor.process(
          action: 'Hello 111-222-3333',
          users: [
            {
              name: 'dewski',
              phone_number: '111-222-3333',
            },
          ],
        )

        expected_result = {
          '.action': [
            {
              label: :phone_number,
              begin: 6,
              end: 18,
            },
          ],
          '.users[0].phone_number': [
            {
              label: :phone_number,
              begin: 0,
              end: 12,
            },
          ],
        }

        assert_equal expected_result, result.to_h
      ensure
        Cased::Sensitive::Handler.handlers = old_handlers
      end

      def test_mutates_audit_event_if_using_bang_method
        old_handlers = Cased::Sensitive::Handler.handlers
        Cased::Sensitive::Handler.handlers = []
        Cased::Sensitive::Handler.register(:phone_number, /\d{3}\-\d{3}\-\d{4}/)
        audit_event = {
          body: 'Hello 111-222-3333',
        }
        Cased::Sensitive::Processor.process!(audit_event)

        expected_event = {
          body: 'Hello 111-222-3333',
          '.cased': {
            pii: {
              '.body': [
                {
                  label: :phone_number,
                  begin: 6,
                  end: 18,
                },
              ],
            },
          },
        }

        assert_equal expected_event, audit_event
      ensure
        Cased::Sensitive::Handler.handlers = old_handlers
      end
    end
  end
end
