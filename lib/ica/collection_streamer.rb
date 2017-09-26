# frozen_string_literal: true

module ICA
  # In order to render a large collection of {CardAccountMapping} or
  # {CustomerAccountMapping} objects without bloating memory
  # Can be used both in Grape responses and HTTP requests \o/
  class CollectionStreamer
    include Enumerable # mostly for compatibility with HTTP.rb

    def initialize(mappings)
      @mappings = mappings
    end

    def each
      yield "[\n"
      first = true
      # find_each uses batches to avoid having too many queries
      # note that this prevents limit() queries
      @mappings.find_each do |object|
        buffer = if first
                   first = false
                   ''
                 else
                   ",\n"
                 end
        data = buffer + JSON.dump(object.to_json_hash)
        yield data
      end
      yield "\n]"
    end
  end
end
