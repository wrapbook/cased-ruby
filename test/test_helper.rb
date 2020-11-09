# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  add_filter 'lib/cased/extensions/hash/deep_merge.rb'
end

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'cased'

require 'minitest/autorun'
require 'webmock/minitest'
require 'mocha/minitest'
require 'byebug'

module Cased
  class Test < Minitest::Test
    def teardown
      Cased::Context.clear!
      WebMock.reset!
    end

    def suppress_output
      original_stderr = STDERR.clone
      original_stdout = STDOUT.clone
      STDERR.reopen(File.new('/dev/null', 'w'))
      STDOUT.reopen(File.new('/dev/null', 'w'))

      yield
    ensure
      STDERR.reopen(original_stderr)
      STDOUT.reopen(original_stdout)
    end
  end
end
