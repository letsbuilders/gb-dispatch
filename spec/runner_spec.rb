require 'spec_helper'
require 'gb_dispatch/runner'

describe GBDispatch::Runner do

  it 'should execute synchronously' do
    a = :foo
    GBDispatch::Runner.new.execute ->() { a=:bar }
    expect(a).to eq :bar
  end

  it 'should execute async' do
    a = :foo
    GBDispatch::Runner.new.async.execute ->() do
      sleep(0.01)
      a = :bar
    end
    expect(a).to eq :foo
    sleep(0.015)
    expect(a).to eq :bar
  end

  it 'should support Celluloid Conditions' do
    a = :foo
    GBDispatch::Runner.new.async.execute ->() { 5+5 }, :condition => ->(result) { a = result }
    sleep(0.01)
    expect(a).to eq 10
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