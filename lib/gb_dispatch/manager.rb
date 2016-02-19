require 'singleton'
require 'gb_dispatch/runner'
require 'gb_dispatch/queue'
# Queue manager for simulating Grand Central Dispatch behaviour.
#
# It is singleton class, so all calls should be invoked through +GBDispatch::Manager.instance+
module GBDispatch
  class Manager
    include Singleton

    # Returns queue of given name.
    #
    # If queue doesn't exists it will create you a new one.
    # Remember that for each allocated queue, there is new thread allocated.
    # @param name [String, Symbol] if not passed, default queue will be returned.
    # @return [GBDispatch::Queue]
    def get_queue(name=:default_queue)
      name = name.to_sym
      queue = @queues[name]
      unless queue
        @queues[name] = GBDispatch::Queue.new(name)
        queue = @queues[name]
      end
      queue
    end

    # Run asynchronously given block of code on given queue.
    #
    # This is a proxy for {GBDispatch::Queue#perform_now} method.
    # @param queue [GBDispatch::Queue] queue on which block will be executed
    # @return [nil]
    # @example
    #   my_queue = GBDispatch::Manager.instance.get_queue :my_queue
    #   GBDispatch::Manager.instance.run_async_on_queue my_queue do
    #     #my delayed code here - probably slow one :)
    #     puts 'Delayed Hello World!'
    #   end
    def run_async_on_queue(queue)
      raise ArgumentError.new 'Queue must be GBDispatch::Queue' unless queue.is_a? GBDispatch::Queue
      queue.async.perform_now ->() { yield }
    end

    # Run given block of code on given queue and wait for result.
    #
    # This method use {GBDispatch::Queue#perform_now} and wait for result.
    # @param queue [GBDispatch::Queue] queue on which block will be executed
    # @example sets +my_result+ to 42
    #   my_queue = GBDispatch::Manager.instance.get_queue :my_queue
    #   my_result = GBDispatch::Manager.instance.run_sync_on_queue my_queue do
    #     # my complicated code here
    #     puts 'Delayed Hello World!'
    #     # return value
    #     42
    #   end
    def run_sync_on_queue(queue)
      raise ArgumentError.new 'Queue must be GBDispatch::Queue' unless queue.is_a? GBDispatch::Queue
      future = queue.await.perform_now ->() { yield }
      future.value
    end

    # Run given block of code on given queue with delay.
    # @param time [Fixnum, Float] delay in seconds
    # @param queue [GBDispatch::Queue] queue on which block will be executed
    # @return [nil]
    # @example Will print 'Hello word!' after 5 seconds.
    #   my_queue = GBDispatch::Manager.instance.get_queue :my_queue
    #   my_result = GBDispatch::Manager.instance.run_after_on_queue 5, my_queue do
    #     puts 'Hello World!'
    #   end
    #
    def run_after_on_queue(time, queue)
      raise ArgumentError.new 'Queue must be GBDispatch::Queue' unless queue.is_a? GBDispatch::Queue
      queue.perform_after time, ->(){ yield }
    end


    # :nodoc:
    def exit
      @queues.each_key do |name|
        @queues[name] = nil
      end
      Runner.pool.shutdown
      Runner.pool.wait_for_termination
    end

    private

    # :nodoc:
    def initialize
      @queues = Concurrent::Map.new
    end
  end
end
