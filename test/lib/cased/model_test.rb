# frozen_string_literal: true

require 'active_support/testing/assertions'

class DefaultModel
  include Cased::Model
end

class ImplementedModel
  include Cased::Model

  def to_s
    'Implemented Model'
  end

  def cased_id
    'ImplementedModel;1'
  end
end

class KernelOwnedToString
  include Cased::Model

  def cased_id
    'KernelOwnedToString;1'
  end
end

class ModelOwnedToString
  include Cased::Model

  def to_s
    'Model Owned To String'
  end

  def cased_id
    'ModelOwnedToString;1'
  end
end

class ModelWithDeepPayload
  include Cased::Model

  def cased_payload
    {
      cased_category => self,
      objects: {
        nested: true,
      },
    }
  end

  def cased_id
    'ImplementedModel;1'
  end
end

module Cased
  class ModelTest < Cased::Test
    include ActiveSupport::Testing::Assertions

    def test_cased_model_category
      assert_equal :default_model, DefaultModel.cased_category
    end

    def test_publishes_events
      old_publishers = Cased.publishers
      test_publisher = Cased::Publishers::TestPublisher.new
      Cased.publishers = [test_publisher]

      model = ImplementedModel.new
      assert_difference 'test_publisher.events.length' do
        model.cased(:action)
      end
    ensure
      Cased.publishers = old_publishers
    end

    def test_published_event_action_name_combines_category_and_action
      old_publishers = Cased.publishers
      test_publisher = Cased::Publishers::TestPublisher.new
      Cased.publishers = [test_publisher]

      model = ImplementedModel.new
      model.cased(:action)

      assert audit_event = test_publisher.events.pop
      assert_equal 'implemented_model.action', audit_event[:action]
    ensure
      Cased.publishers = old_publishers
    end

    def test_set_custom_category_when_recording_audit_event
      old_publishers = Cased.publishers
      test_publisher = Cased::Publishers::TestPublisher.new
      Cased.publishers = [test_publisher]

      model = ImplementedModel.new
      model.cased(:action, category: :custom)

      assert audit_event = test_publisher.events.pop
      assert_equal 'custom.action', audit_event[:action]
    ensure
      Cased.publishers = old_publishers
    end

    def test_set_custom_payload_when_recording_audit_event
      old_publishers = Cased.publishers
      test_publisher = Cased::Publishers::TestPublisher.new
      Cased.publishers = [test_publisher]

      model = ImplementedModel.new
      model.cased(:action)

      assert audit_event = test_publisher.events.pop
      assert_nil audit_event[:test]

      model.cased(:action, payload: { test: true })

      assert audit_event = test_publisher.events.pop
      assert_equal true, audit_event[:test]
    ensure
      Cased.publishers = old_publishers
    end

    def test_payload_is_deeply_merged
      old_publishers = Cased.publishers
      test_publisher = Cased::Publishers::TestPublisher.new
      Cased.publishers = [test_publisher]

      model = ModelWithDeepPayload.new
      model.cased(:action, payload: { objects: { merged: true } })
      expected_payload = {
        nested: true,
        merged: true,
      }

      assert audit_event = test_publisher.events.pop
      assert_equal expected_payload, audit_event[:objects]
    ensure
      Cased.publishers = old_publishers
    end

    def test_payload_contains_sensitive_value
      old_publishers = Cased.publishers
      test_publisher = Cased::Publishers::TestPublisher.new
      Cased.publishers = [test_publisher]

      model = ModelOwnedToString.new
      model.cased(:action)

      assert audit_event = test_publisher.events.pop
      assert_equal 'Model Owned To String', audit_event[:model_owned_to_string]
    ensure
      Cased.publishers = old_publishers
    end

    def test_implemented_model_cased_human
      model = ImplementedModel.new

      assert_equal 'Implemented Model', model.cased_human
    end

    def test_default_model_cased_payload
      model = DefaultModel.new

      expected_payload = {
        default_model: model,
      }
      assert_equal expected_payload, model.cased_payload
    end

    def test_cased_context_with_kernel_to_s
      model = KernelOwnedToString.new

      expected_context = {
        kernel_owned_to_string_id: 'KernelOwnedToString;1',
      }
      assert_equal expected_context, model.cased_context
    end

    def test_cased_context_with_custom_to_s
      model = ModelOwnedToString.new

      expected_context = {
        model_owned_to_string_id: 'ModelOwnedToString;1',
        model_owned_to_string: Cased::Sensitive::String.new('Model Owned To String', label: 'ModelOwnedToString'),
      }
      assert_equal expected_context, model.cased_context
    end
  end
end
