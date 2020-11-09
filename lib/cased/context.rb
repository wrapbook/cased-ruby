# frozen_string_literal: true

require 'cased/context/expander'
require 'active_support/core_ext/hash/deep_merge'

module Cased
  class Context
    def self.current
      Thread.current[:cased_context] ||= new
    end

    def self.current=(context)
      Thread.current[:cased_context] = new(context)
    end

    def self.clear!
      Thread.current[:cased_context] = nil
    end

    attr_reader :context

    def initialize(context = {})
      @context = Cased::Context::Expander.expand(context || {})
    end

    def clear
      @context = {}
    end

    def merge(new_context = {})
      if block_given?
        old_context = @context.dup
        @context.deep_merge!(Cased::Context::Expander.expand(new_context))
        yield
      else
        @context.deep_merge!(Cased::Context::Expander.expand(new_context))
      end
    ensure
      @context = old_context if block_given?
    end

    def [](key)
      @context[key]
    end

    def []=(key, value)
      merge(key => value)
    end
  end
end
