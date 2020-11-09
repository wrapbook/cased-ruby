# frozen_string_literal: true

require 'cased/error'

module Cased
  module Publishers
    # Public: Standard exception class all Cased publisher errors inherit from.
    class Error < Cased::Error
    end
  end
end
