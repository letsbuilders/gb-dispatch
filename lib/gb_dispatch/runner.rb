require 'celluloid'
module GbDispatch
  class Runner
    include Celluloid

    def execute(block, condition=nil)
      begin
        result = block.call
        condition.call(result) if condition
        result
      rescue Exception => e
        if defined?(Opbeat)
          Opbeat.set_context extra: {queue: :name}
          Opbeat.capture_exception(e)
        end
        puts e.message
        puts e.backtrace.join("\n")
        condition.call(nil)
        raise e
      end
    end
  end
end
