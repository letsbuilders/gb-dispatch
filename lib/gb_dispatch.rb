require 'gb_dispatch/version'
require 'gb_dispatch/manager'

# Library to dispatch block on queues.
# It is inspired by GCD but implementation is based on Celluloid.
# Current implementation ensure that block on queue will be executed in the same order
# as added, however it doesn't ensure on which thread it will run.
#
# == Threading
# Each queue have it is own thread, but their only for synchronisation.
# All execution happens on runners thread pool. Pool size is limited to number of cores
# of the machine.
#
module GBDispatch
  # Dispatch asynchronously on queue
  # @param queue [Symbol, GBDispatch::Queue] queue object or name
  # @yield block to execute
  def self.dispatch_async_on_queue(queue)
    queue = GBDispatch::Manager.instance.get_queue(queue) unless queue.is_a? GBDispatch::Queue
    GBDispatch::Manager.instance.run_async_on_queue queue do
      yield
    end
  end

  # Get queue of given name
  # @return [GBDispatch:Queue]
  # @param name [#to_sym]
  def self.get_queue(name)
    GBDispatch::Manager.instance.get_queue(name)
  end

  # Dispatch synchronously on queue and return result
  # @param queue [Symbol, GBDispatch::Queue] queue object or name
  # @yield block to execute
  def self.dispatch_sync_on_queue(queue)
    queue = GBDispatch::Manager.instance.get_queue(queue) unless queue.is_a? GBDispatch::Queue
    GBDispatch::Manager.instance.run_async_on_queue queue do
      yield
    end
  end

  # Setup logger. By default it use Celluloid logger
  # @param logger [Logger]
  def self.logger=(logger)
    Celluloid.logger = logger
  end
end
