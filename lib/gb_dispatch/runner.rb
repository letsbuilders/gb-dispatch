require 'concurrent'
module GBDispatch
  class Runner
    class << self
      attr_accessor :pool_size

      # Thread pool for async execution.
      # Pool size is set by default to core numbers or at least 2.
      # You can increase size of pool by setting :pool_size variable before using pool.
      # @return [Concurrent::ThreadPoolExecutor]
      def pool
        unless @pool
          self.pool_size ||=2
          threads = [self.pool_size, 2, Concurrent.processor_count].max
          @pool = Concurrent::ThreadPoolExecutor.new(
              min_threads: 2,
              max_threads: threads,
              max_queue: 10*threads,
              fallback_policy: :caller_runs
          )
        end
        @pool
      end

      # Execute given block.
      # If there is an exception thrown, it log it and crash actor.
      # For more information about error handling, check Celluloid documentation.
      # @param block [Proc]
      # @param options [Hash]
      # @option options [String] :name queue name used for debugging and better logging.
      def execute(block, options=Hash.new)
        future = Concurrent::Future.new(:executor => self.pool) do
          begin
            name = options[:name]
            Thread.current[:name] ||= name if name
            result = block.call
            result
          rescue Exception => e
            if defined?(Opbeat)
              Opbeat.set_context extra: {queue: name} if name
              Opbeat.capture_exception(e)
            end
            GBDispatch.logger.error "Failed execution of queue #{name} with error #{e.message}" if GBDispatch.logger
            raise e
          end
        end
        future.execute
        future.value
        if future.rejected?
          raise future.reason
        end
        future.value
      end
    end
  end
end
