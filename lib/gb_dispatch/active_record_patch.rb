if defined?(ActiveRecord)
  module ActiveRecord
    module ConnectionAdapters
      class ConnectionPool
        def force_new_connection
          old_lock = @lock_thread
          @lock_thread = nil
          with_connection do |conn|
            yield conn
          end
        ensure
          @lock_thread = old_lock
        end
      end
    end
  end
end