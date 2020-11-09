# frozen_string_literal: true

require 'active_support/concern'
require 'active_support/inflector'
require 'active_support/core_ext/hash/deep_merge'
require 'cased/context'

module Cased
  module Model
    extend ActiveSupport::Concern

    module ClassMethods
      # Establishes a default `cased_category` that matches nicely to
      # the class name. The default instance level `cased_category` uses this.
      #
      # @return [Symbol]
      def cased_category
        @cased_category ||= begin
          category = ActiveSupport::Inflector.underscore(name)
          category.to_sym
        end
      end
    end

    # Instruments events for the model. These events are sent directly to Cased.
    #
    # @param action [String, Symbol] suffix of the action.
    # @param category [String, Symbol] action category name.
    # @param payload [Hash] additional payload information about the event.
    #
    # @return [Array] of responses from Cased.publishers
    def cased(action, category: cased_category, payload: {})
      body = cased_payload.deep_merge(payload)

      Cased.publish(body.merge(action: "#{category}.#{action}"))
    end

    # Defines the event key prefix for all model events.
    #
    # Defaults to :my_model if the class this thing is included in is MyModel.
    # Feel free to override to provide a more semantic, meaningful name
    # if you so desire.
    #
    # @return [String]
    def cased_category
      self.class.cased_category
    end

    # Defines the default payload for every event.
    #
    # @return [Hash]
    def cased_payload
      {
        cased_category => self,
      }
    end

    # Defines the Cased identifier for the current instance.
    #
    # @example
    #   user.cased_id # => User;1
    #
    # @example
    #   client.cased_id # => Client;1
    #
    # @raise [Cased::Error::MissingIdentifier] description
    # @return [String]
    def cased_id; end

    # Internal: The String representation within the Cased object.
    #
    # @return [String] if cased_category key is present in cased_context.
    def cased_human
      cased_context[cased_category]
    end

    # Internal: Defines the payload to describe the current subject.
    # Can be overridden in model to change fields returned.
    #
    # @param [String, Symbol] category prefix that can be set to override Hash prefix.
    #
    # @example
    #   model.cased_context # => { user_id: "User;1", user: "flynn" }
    #   model.cased_context(category: :actor) # => { actor_id: "User;1", actor: "flynn" }
    #
    # @return [Hash]
    def cased_context(category: cased_category)
      context = {}
      context["#{category}_id".to_sym] = cased_id if cased_id

      if method(:to_s).owner == self.class
        context[category] = Cased::Sensitive::String.new(to_s, label: self.class.name)
      end

      context
    end
  end
end
