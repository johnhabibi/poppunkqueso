module Telemetry
  class FailureLogger
    @mutex = Mutex.new
    @last_seen = {}

    class << self
      def warn_rate_limited(key, message, interval: 60)
        should_log = false
        now = Process.clock_gettime(Process::CLOCK_MONOTONIC)

        @mutex.synchronize do
          last = @last_seen[key]
          if last.nil? || (now - last) >= interval
            @last_seen[key] = now
            should_log = true
          end
        end

        Rails.logger.warn(message) if should_log
      end
    end
  end
end
