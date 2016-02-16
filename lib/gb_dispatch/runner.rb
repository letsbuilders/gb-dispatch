require 'celluloid/current'
module GBDispatch
  class Runner
    include Celluloid

    # Execute given block.
    # If there is an exception thrown, it log it and crash actor.
    # For more information about error handling, check Celluloid documentation.
    # @param block [Proc]
    # @param options [Hash]
    # @option options [Proc] :condition celluloid condition block called on finish with result
    # @option options [String] :name queue name used for debugging and better logging.
    def execute(block, options=Hash.new)
      begin
        condition = options[:condition]
        result = block.call
        condition.call(result) if condition
        result
      rescue Exception => e
        name = options[:name]
        if defined?(Opbeat)
          Opbeat.set_context extra: {queue: name} if name
          Opbeat.capture_exception(e)
        end
        Celluloid.logger.error "Failed execution of queue #{name} with error #{e.message}"
        condition.call(e) if condition
        raise e
      end
    end
  end
end
