# frozen_string_literal: true

class EmptyImplementationModel
  include Cased::Model
end

class DefaultModel
  include Cased::Model

  def to_s
    'DefaultModel'
  end
end

module Cased
  class TestHelperTest < Cased::Test
    include Cased::TestHelper

    def test_assert_cased_events_without_block
      model = DefaultModel.new
      model.cased(:action)

      assert_cased_events 1
    end

    def test_assert_cased_events_inside_block
      model = DefaultModel.new
      model.cased(:action)

      assert_cased_events 2 do
        model.cased(:action)
        model.cased(:action)
      end
    end

    def test_assert_cased_events_with_filter_requires_property
      default_model = EmptyImplementationModel.new
      default_model.cased(:action)

      assert_empty default_model.cased_context

      exception = assert_raises(ArgumentError) do
        assert_cased_events 1, default_model: default_model
      end

      expected_message = <<~MSG.strip
        cased_events_with would have matched any published Cased event.

        cased_events_with was called with {:default_model=>#{default_model.inspect}} but resulted into {} after it was expanded.

        This typically happens when an object that includes Cased::Model does not implement either the #cased_id or #to_s method.
      MSG

      assert_equal expected_message, exception.message
    end

    def test_assert_cased_events_filter_with_cased_model
      default_model = DefaultModel.new
      default_model.cased(:action)

      assert_cased_events 1, default_model: default_model
    end

    def test_assert_cased_events_filters_string_or_symbol_key
      model = DefaultModel.new
      model.cased(:action)

      assert_cased_events 2, 'action' => 'default_model.action' do
        assert_cased_events 2, action: 'default_model.action' do
          model.cased(:action)
          model.cased(:action)
        end
      end
    end

    def test_assert_cased_events_with_block_and_filters
      model = DefaultModel.new
      model.cased(:action)

      assert_cased_events 2, action: 'default_model.action' do
        model.cased(:action)
        model.cased(:action)
      end

      assert_cased_events 1, action: 'default_model.action', extra: true do
        model.cased(:action)
        model.cased(:action, payload: { extra: true })
      end
    end

    def test_assert_cased_events_with_nested_filters
      model = DefaultModel.new
      model.cased(:action)

      assert_cased_events 1, nested: { object: true } do
        model.cased(:action)
        model.cased(:action, payload: { nested: { object: true } })
      end
    end

    def test_assert_cased_events_without_block_and_filters
      model = DefaultModel.new
      model.cased(:action)
      model.cased(:action)
      model.cased(:action)

      assert_cased_events 3, action: 'default_model.action'
    end

    def test_cased_events_with_returns_array_of_hashes
      model = DefaultModel.new
      model.cased(:action)

      events = cased_events_with action: 'default_model.action'
      assert_kind_of Hash, events.first
    end

    def test_assert_no_cased_events_with_block
      model = DefaultModel.new
      model.cased(:action)

      called = false
      assert_no_cased_events do
        called = true
      end

      assert called
    end

    def test_assert_no_cased_events_with_block_and_filter
      model = DefaultModel.new
      model.cased(:action)

      assert_no_cased_events action: 'user.login' do
        model.cased(:action)
        model.cased(:action)
      end
    end

    def test_assert_no_cased_events_without_block
      assert_no_cased_events
    end
  end
end
