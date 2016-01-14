require 'singleton'
require 'gb_dispatch/manager'
class CentralDispatch
  include Singleton

  def dispatch_async(block=nil)
    GBDispatch::Manager.instance.run_async_on_queue GBDispatch::Manager.instance.get_queue do
      block ? block.call : yield
    end
  end

  class << self
    def dispatch_async(block=nil)
      GBDispatch::Manager.instance.run_async_on_queue GBDispatch::Manager.instance.get_queue do
        block ? block.call : yield
      end
    end
  end
end