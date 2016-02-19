require 'spec_helper'
require 'gb_dispatch/runner'

describe GBDispatch::Runner do

  it 'should execute synchronously' do
    a = :foo
    GBDispatch::Runner.execute ->() { a=:bar }
    expect(a).to eq :bar
  end

  it 'should return result of passed block' do
    a = GBDispatch::Runner.execute ->() { :bar }
    expect(a).to eq :bar
  end

  it 'should execute on different thread' do
    Thread.current[:name] = :foo
    a = :foo
    GBDispatch::Runner.execute ->() do
      a = Thread.current[:name]
    end, name: :bar
    expect(a).not_to eq :foo
  end


  context 'error handling' do
    it 'should call Celluloid Conditions with exception' do
      expect { GBDispatch::Runner.execute ->() { raise StandardError.new 'Test' }, name: :fail_test }.to raise_error StandardError
    end
  end
end