require 'angellist_api'

module Resque
  module Plugins
    module RateLimitedQueue
      class AngellistQueue
        extend Resque::Plugins::RateLimitedQueue
        WAIT_TIME = 60
        @queue = :angellist_api

        def self.perform(klass, *params)
          class_from_string(klass).perform(*params)
        rescue AngellistApi::Error::TooManyRequests
          pause_for(Time.now + (60 * 60), name)
          rate_limited_requeue(self, klass, *params)
        end

        def self.enqueue(klass, *params)
          rate_limited_enqueue(self, klass, *params)
        end
      end
    end
  end
end
