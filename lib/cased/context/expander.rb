# frozen_string_literal: true

module Cased
  class Context
    class Expander
      def self.expand(payload)
        return {} if payload.nil?
        return payload unless payload.respond_to?(:each)

        cased_payload = payload.dup
        payload.each do |key, value|
          if value.respond_to?(:cased_context)
            cased_payload.delete(key)
            cased_payload.update(value.cased_context(category: key))
          elsif value.is_a?(Hash)
            cased_payload[key] = expand(value)
          elsif value.is_a?(Array)
            values = value.collect do |val|
              if val.respond_to?(:cased_context)
                val.cased_context
              else
                val
              end
            end
            cased_payload.update(key => values)
          end
        end

        cased_payload
      end
    end
  end
end
