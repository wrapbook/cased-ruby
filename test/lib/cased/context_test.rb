# frozen_string_literal: true

module Cased
  class ContextTest < Cased::Test
    def test_clearing_context
      context = Cased::Context.new
      context[:test] = true

      assert_equal true, context[:test]

      context.clear

      assert_nil context[:test]
    end

    def test_setting_single_context_value
      context = Cased::Context.new
      assert_nil context[:key]

      context[:key] = 'value'

      assert_equal 'value', context[:key]
    end

    def test_merge
      context = Cased::Context.new

      context.merge(action: 'user.login')
      expected_context = {
        action: 'user.login',
      }
      assert_equal expected_context, context.context
    end

    def test_merge_with_block_sets_inner_context
      context = Cased::Context.new

      context.merge(action: 'user.login')
      expected_context = {
        action: 'user.login',
      }
      assert_equal expected_context, context.context

      context.merge(company: 'cased') do
        expected_block_context = {
          action: 'user.login',
          company: 'cased',
        }

        assert_equal expected_block_context, context.context
      end

      assert_equal expected_context, context.context
    end

    def test_merge_performs_deep_merge
      context = Cased::Context.new
      context.merge(action: 'user.login', object: { deep: true })
      context.merge(object: { hash: true })

      expected_context = {
        action: 'user.login',
        object: {
          deep: true,
          hash: true,
        },
      }
      assert_equal expected_context, context.context
    end

    def test_merge_nil_value_with_block
      context = Cased::Context.new
      called = false
      context.merge(nil) do
        called = true
      end

      assert called, 'expected context block to be called on nil value'
    end

    class TestCasedContext
      def initialize(name)
        @name = name
      end

      def cased_context(category: :test_context)
        {
          category => @name,
        }
      end
    end

    def test_merge_expands_context
      object_with_context = TestCasedContext.new('cased')
      context = Cased::Context.new
      context.merge(test_context: object_with_context)

      expected_context = {
        test_context: 'cased',
      }
      assert_equal expected_context, context.context
    end

    def test_merge_expands_context_with_block
      object_with_context = TestCasedContext.new('cased')
      context = Cased::Context.new
      context.merge(test_context: object_with_context) do
        expected_context = {
          test_context: 'cased',
        }
        assert_equal expected_context, context.context
      end

      assert_empty context.context
    end

    def test_setting_single_context_value_with_expandable_context
      object_with_context = TestCasedContext.new('cased')
      context = Cased::Context.new

      context[:key] = object_with_context

      assert_equal 'cased', context[:key]
    end
  end
end
