# frozen_string_literal: true

require 'test_helper'

module Cased
  class Context
    class ExpanderTest < Cased::Test
      class TestObject
        def initialize(name)
          @name = name
        end

        def cased_context(category: :test_object)
          {
            category => @name,
          }
        end
      end

      def test_does_not_mutate_original_payload
        test_object = TestObject.new('cased')
        original_payload = {
          test_object: test_object,
        }

        Cased::Context::Expander.expand(original_payload)

        expected_payload = {
          test_object: test_object,
        }

        assert_equal expected_payload, original_payload
      end

      def test_performs_expansion_with_key_value
        test_object = TestObject.new('cased')
        actual_payload = Cased::Context::Expander.expand(test_object: test_object)

        expected_payload = {
          test_object: 'cased',
        }

        assert_equal expected_payload, actual_payload
      end

      def test_performs_expansion_with_custom_keys
        test_object = TestObject.new('cased')
        actual_payload = Cased::Context::Expander.expand(
          test_object: test_object,
          custom_key: test_object,
        )

        expected_payload = {
          test_object: 'cased',
          custom_key: 'cased',
        }

        assert_equal expected_payload, actual_payload
      end

      def test_performs_expansion_with_array
        test_object = TestObject.new('cased')
        actual_payload = Cased::Context::Expander.expand(
          test_objects: [test_object, test_object, true],
        )

        expected_payload = {
          test_objects: [
            {
              test_object: 'cased',
            },
            {
              test_object: 'cased',
            },
            true,
          ],
        }

        assert_equal expected_payload, actual_payload
      end

      def test_performs_expansion_with_nested_object
        test_object = TestObject.new('cased')
        actual_payload = Cased::Context::Expander.expand(
          first: {
            second: {
              key: test_object,
            },
          },
        )

        expected_payload = {
          first: {
            second: {
              key: 'cased',
            },
          },
        }

        assert_equal expected_payload, actual_payload
      end

      class TestObjectWithMultipleContextKeys
        def initialize(name)
          @name = name
        end

        def cased_context(category: :test_object)
          {
            category => @name,
            "#{category}_id".to_sym => 'TestObject;1',
          }
        end
      end

      def test_adds_all_keys_from_cased_context
        test_object = TestObjectWithMultipleContextKeys.new('cased')
        actual_payload = Cased::Context::Expander.expand(test_object: test_object)

        expected_payload = {
          test_object: 'cased',
          test_object_id: 'TestObject;1',
        }

        assert_equal expected_payload, actual_payload
      end

      def test_nested_context_adds_all_keys
        test_object = TestObjectWithMultipleContextKeys.new('cased')
        actual_payload = Cased::Context::Expander.expand(
          first: {
            second: {
              key: test_object,
            },
          },
        )

        expected_payload = {
          first: {
            second: {
              key: 'cased',
              key_id: 'TestObject;1',
            },
          },
        }

        assert_equal expected_payload, actual_payload
      end
    end
  end
end
