# frozen_string_literal: true

module Cased
  class Error < StandardError
    SystemActorMissing = Class.new(self)
    MissingIdentifier = Class.new(self)
  end
end
