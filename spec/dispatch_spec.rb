require 'spec_helper'
require 'gb_dispatch'

describe GBDispatch do

  it 'should run dispatch_async' do
    a = []
    GBDispatch.dispatch_async :test do
      sleep(0.01)
      a << 1
    end
    GBDispatch.dispatch_async :test do
      a << 2
    end
    expect(a.empty?).to be_truthy
    sleep(0.03)
    expect(a).to eq [1, 2]
  end

  it 'should run dispatch_async_on_queue' do
    a = []
    GBDispatch.dispatch_async_on_queue :test do
      sleep(0.01)
      a << 1
    end
    GBDispatch.dispatch_async_on_queue :test do
      a << 2
    end
    GBDispatch.dispatch_async_on_queue :test do
      a << 3
    end
    expect(a.empty?).to be_truthy
    sleep(0.02)
    expect(a).to eq [1, 2, 3]
  end

  it 'should run dispatch_sync' do
    a = []
    GBDispatch.dispatch_async :test do
      sleep(0.02)
      a << 1
    end
    result = GBDispatch.dispatch_sync :test do
      a << 2
      a
    end
    expect(result).to eq [1,2]
  end

  it 'should run dispatch_sync_on_queue' do
    a = []
    GBDispatch.dispatch_async :test do
      sleep(0.02)
      a << 1
    end
    result = GBDispatch.dispatch_sync_on_queue :test do
      a << 2
      a
    end
    expect(result).to eq [1,2]
  end

  it 'should run dispatch_after' do
    a = []
    GBDispatch.dispatch_after 0.1, :test do
      a << 1
    end
    sleep(0.01)
    expect(a.empty?).to be_truthy
    sleep(0.15)
    expect(a).to eq [1]
  end

  it 'should run dispatch_after_on_queue' do
    a = []
    GBDispatch.dispatch_after_on_queue 0.1, :test do
      a << 1
    end
    sleep(0.01)
    expect(a.empty?).to be_truthy
    sleep(0.2)
    expect(a).to eq [1]
  end

  it 'should return proper queue' do
    queue = GBDispatch.get_queue :test
    expect(queue).to be_a GBDispatch::Queue
    expect(queue.name).to eq :test
    expect(GBDispatch.get_queue :test).to equal queue
  end
end