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
        if defined?(Rails) && defined?(Rails::VERSION::MAJOR)
          if Rails::VERSION::MAJOR < 5
            _execute(block, options)
          else
            _execute_rails(block, options)
          end
        else
          _execute(block, options)
        end
      end

      private

      def _execute(block, options)
        future = Concurrent::Future.new(:executor => self.pool) do
          _run_block(block, options)
        end
        future.execute
        future.value
        if future.rejected?
          raise future.reason
        end
        future.value
      end

      def _execute_rails(block, options)
        if defined?(Rails) && defined?(ActiveSupport::Dependencies)
          future = Concurrent::Future.new(:executor => self.pool) do
            Rails.application.executor.wrap do
              ActiveSupport::Dependencies.interlock.permit_concurrent_loads do
                _run_block(block, options)
              end
            end
          end
          future.execute
          ActiveSupport::Dependencies.interlock.permit_concurrent_loads { future.value }
          if future.rejected?
            raise future.reason
          end
          future.value
        else
          raise 'Failed loading rails!'
        end
      end

      def _run_block(block, options)
        begin
          name = options[:name]
          Thread.current[:name] ||= name if name
          result = block.call
          result
        rescue Exception => e
          if defined?(Raven)
            Raven.tags_context :gb_dispacth => true
            Raven.extra_context :dispatch_queue => name
            Raven.capture_exception(e)
          end
          GBDispatch.logger.error "Failed execution of queue #{name} with error #{e.message}"
          raise e
        end
      end
    end
  end
end
