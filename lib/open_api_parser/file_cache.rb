# frozen_string_literal: true

module OpenApiParser
  class FileCache
    def initialize
      @cache = {}
    end

    def get(key, &block)
      return @cache[key] if @cache.key?(key)

      block.call.tap do |result|
        @cache[key] = result
      end
    end
  end
end
