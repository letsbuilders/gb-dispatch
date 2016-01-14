require 'celluloid'
module GBDispatch
  class Queue
    include Celluloid

    # @return [String] queue name
    attr_reader :name

    # @param name [String] queue name, should be the same as is register in Celluloid
    # @param thread_pool [Celluloid::Pool] pool of runners for executing code.
    def initialize(name, thread_pool)
      @name = name
      @thread_pool = thread_pool
    end

    # Perform given block
    #
    # If used with rails it will wrap block with connection pool.
    # @param block [Proc]
    # @yield if there is no block given it yield without param.
    # @return [Object, Exception] returns value of executed block or exception if block execution failed.
    def perform(block=nil)
      Thread.current[:name] ||= name
      if defined?(Rails) && defined?(ActiveRecord::Base)
        thread_block = ->() do
          begin
            ActiveRecord::Base.connection_pool.with_connection do
              block ? block.call : yield
            end
          ensure
            ActiveRecord::Base.clear_active_connections!
          end
        end
      else
        thread_block = block ? block : ->() { yield }
      end
      exclusive do
        begin
          @thread_pool.execute thread_block, name: name
        rescue Exception => e
          return e
        end
      end
    end

    # Perform block after given period
    # @param time [Fixnum]
    # @param block [Proc]
    # @yield if there is no block given it yield without param.
    def perform_after(time, block=nil)
      after(time) do
        block = ->(){ yield } unless block
        self.async.perform block
      end
    end
  end
end
