require 'singleton'
require 'gb_dispatch/runner'
require 'gb_dispatch/queue'
module GbDispatch
  class Manager
    include Singleton

    def get_queue(name=:default)
      queue = Celluloid::Actor[name]
      unless queue
        supervisor = Queue.supervise_as name, name, @pool
        queue = supervisor.actors.first
      end
      queue
    end

    # @param queue [GbDispatch::Queue]
    def run_async_on_queue(queue)
      queue.async.perform ->() { yield }
    end

    # @param queue [GbDispatch::Queue]
    def run_sync_on_queue(queue)
      future = queue.future.perform ->() { yield }
      future.value
    end

    private

    def initialize
      @pool = Runner.pool
    end
  end
end
