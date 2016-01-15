# GBDispatch

Library allows to easily dispatch block of code for queues.
It is inspired by Grand Central Dispatch behaviour.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'gb_dispatch'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gb_dispatch

Then in your script

```ruby
require 'gb_dispatch'
```

## Usage

To dispatch asynchronously

```ruby
GBDispatch.dispatch_async :my_queue do
    puts 'my code here'
end
```

for synchronous execution

```ruby
my_result = GBDispatch.dispatch_sync :my_queue do
    puts 'my code here'
end
```

for delay execution

```ruby
delay = 4.5 #seconds
GBDispatch.dispatch_after delay, :my_queue do
    puts 'my code here'
end
```

### Using with Rails

If you are using Rails, all blocks are wrapped in connection pool, 
so you don't need to worry about creating and removing new connections.
Only thing you need to do, is to increase connection pool size
by number of cores of your machine.

## How it works

### Queues

For each created queue there is a new thread created. However this threads
are used only for scheduling purpose. All code execution happens on execution pool.

Queues ensure order of execution, but they don't guarantee that all blocks from one queue 
will be executed on the same thread. 

### Execution pool

This is pool of thread where your code will be executed. 
Amount of threads in the pool match the amount of cores of your machine 
(except if you have only one core, there will be 2 threads).

### Exceptions

GBDispatch is designed in the way, that if there is exception thrown it will not crash the whole app/script.
All exceptions will be logged. If you use +#dispatch_sync+ method, thrown exception will be returned as a result of your block.

## Contributing

1. Fork it ( https://github.com/GenieBelt/gb_dispatch/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
