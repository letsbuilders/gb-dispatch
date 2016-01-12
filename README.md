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

## Usage

To dispatch asynchronously

```ruby
GBDispatch.dispatch_async_on_queue :my_queue do
    puts 'my code here'
end
```

for synchronous execution

```ruby
GBDispatch.dispatch_sync_on_queue :my_queue do
    puts 'my code here'
end
```

### Using with Rails

If you are using Rails, all blocks are wrapped in connection pool, 
so you don't need to worry about creating and removing new connections.
Only thing you need to do, is to increase connection pool size
by number of cores of your machine.

## Contributing

1. Fork it ( https://github.com/GenieBelt/gb_dispatch/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
