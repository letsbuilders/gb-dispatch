require 'spec_helper'
require 'gb_dispatch/queue'
require 'gb_dispatch/runner'


describe GBDispatch::Queue do
  before(:all) { @pool = GBDispatch::Runner.pool }
  after(:all) { @pool.terminate }

  context 'synchronous' do
    it 'should execute lambda' do
      a = :foo
      queue = GBDispatch::Queue.new(:test, @pool)
      queue.perform ->() { a = :bar }
      expect(a).to eq :bar
      queue.terminate
    end

    it 'should execute block' do
      a = :foo
      queue = GBDispatch::Queue.new(:test, @pool)
      queue.perform do
        a = :bar
      end
      expect(a).to eq :bar
      queue.terminate
    end

    it 'should return value of the block' do
      queue = GBDispatch::Queue.new(:test, @pool)
      a = queue.perform do
        :bar
      end
      expect(a).to eq :bar
      queue.terminate
    end

    it 'should return exception object on failure' do
      queue = GBDispatch::Queue.new(:test, @pool)
      a = queue.perform ->() do
        raise StandardError.new 'Test error'
      end
      expect(a).to be_kind_of StandardError
      queue.terminate
    end
  end

  context 'asynchronous' do
    it 'should execute in proper order - one after each other' do
      a = []
      queue = GBDispatch::Queue.new(:test, @pool)
      queue.async.perform ->() do
        (0..10).each { |x| (a << x) && sleep(0.005) }
      end
      queue.async.perform ->() do
        (11..20).each { |x| a << x }
      end
      sleep(0.08)
      expect(a).to eq (0..20).to_a
      queue.terminate
    end

    it 'should handle failures nicely' do
      queue = GBDispatch::Queue.new(:test, @pool)
      a = :foo
      queue.async.perform ->() do
        raise StandardError.new 'Test error'
      end
      queue.async.perform ->() do
        a = :bar
      end
      sleep(0.05)
      expect(a).to eq :bar
      queue.terminate
    end
  end

  context 'after' do
    it 'should bea bale to run block of code after specified time' do
      a = []
      queue = GBDispatch::Queue.new(:test, @pool)
      queue.perform_after 0.5, ->() { a << rand() }
      queue.perform_after 0.7, ->() { a << rand() }
      sleep 0.4
      expect(a.count).to eq 0
      sleep 0.2
      expect(a.count).to eq 1
      sleep 0.2
      expect(a.count).to eq 2
      queue.terminate
    end
  end

  context 'rails' do
    before(:each) do
      class Rails
      end
      module ActiveRecord
        class Base
          class DummyConnectionPool
            def with_connection
              yield
            end
          end

          def self.connection_pool
            @pool ||= DummyConnectionPool.new
          end

          def self.clear_active_connections!
            true
          end
        end
      end
    end

    after(:each) do
      begin
        Kernel.send :remove_const, 'Rails'
        Kernel.send :remove_const, 'ActiveRecord'
      rescue
        nil
      end
      begin
        Object.send :remove_const, 'Rails'
        Object.send :remove_const, 'ActiveRecord'
      rescue
        nil
      end
      begin
        BasicObject.send :remove_const, 'Rails'
        BasicObject.send :remove_const, 'ActiveRecord'
      rescue
        nil
      end
      raise 'dupa' if defined? Rails
    end

    it 'should wrap execution with connection pool' do
      a = :foo
      queue = GBDispatch::Queue.new(:test, @pool)
      expect(ActiveRecord::Base.connection_pool).to receive(:with_connection).and_call_original
      expect(ActiveRecord::Base).to receive(:clear_active_connections!)
      queue.perform do
        a = :bar
      end
      expect(a).to eq :bar
      queue.terminate
    end
  end
end