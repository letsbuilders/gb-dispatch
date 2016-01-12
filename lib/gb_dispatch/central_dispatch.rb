require 'singleton'
require 'gb_dispatch/manager'
class CentralDispatch
  include Singleton

  def dispatch_async(block=nil)
    GbDispatch::Manager.instance.run_async_on_queue GbDispatch::Manager.instance.get_queue do
      block ? block.call : yield
    end
  end

  class << self
    def dispatch_async(block=nil)
      GbDispatch::Manager.instance.run_async_on_queue GbDispatch::Manager.instance.get_queue do
        block ? block.call : yield
      end
    end
  end

end