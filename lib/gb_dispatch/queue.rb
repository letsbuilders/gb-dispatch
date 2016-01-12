require 'celluloid'
require 'celluloid/logging'
module GbDispatch
  class Queue
    include Celluloid
    # include Celluloid::Internals::Logger
    attr_reader :name

    def initialize(name, thread_pool)
      @name = name
      @thread_pool = thread_pool
    end

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
        @thread_pool.execute thread_block
      end
    end
  end
end
