require 'spec_helper'
require 'gb_dispatch/runner'

describe GBDispatch::Runner do

  it 'should execute synchronously' do
    a = :foo
    actor = GBDispatch::Runner.new
    actor.execute ->() { a=:bar }
    expect(a).to eq :bar
    actor.terminate
  end

  it 'should return result of passed block' do
    actor = GBDispatch::Runner.new
    a = actor.execute ->() { :bar }
    expect(a).to eq :bar
    actor.terminate
  end

  it 'should execute async' do
    a = :foo
    actor = GBDispatch::Runner.new
    actor.async.execute ->() do
      sleep(0.01)
      a = :bar
    end
    expect(a).to eq :foo
    sleep(0.015)
    expect(a).to eq :bar
    actor.terminate
  end

  it 'should support Celluloid Conditions' do
    a = :foo
    actor = GBDispatch::Runner.new
    actor.async.execute ->() { 5+5 }, :condition => ->(result) { a = result }
    sleep(0.01)
    expect(a).to eq 10
    actor.terminate
  end

  context 'error handling' do
    it 'should call Celluloid Conditions with exception' do
      a = :foo
      actor = GBDispatch::Runner.new
      actor.async.execute ->() { raise StandardError.new 'Test' }, :condition => ->(result) { a = result }, name: :fail_test
      sleep(0.01)
      expect(a).to be_kind_of StandardError
      expect(actor.alive?).to be_falsey
    end
  end
end