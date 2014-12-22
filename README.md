# ResqueRateLimitedQueue

A Resque plugin which makes handling rate limited apis easier

If you have a series of jobs in a queue, this gem will pause the queue when one of the jobs hits a rate limit, and re-start the queue when the rate limit has expired.

There are two ways to use the gem.

If the api you are using has a dedicated queue included in the gem (currently Twitter, Angellist and Evernote) then you just need to make some very minor changes to how you queue jobs, and the gem will do the rest.

If you are using another API, then you need to write a little code that catches the rate limit signal.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'resque_rate_limited_queue'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install resque_rate_limited_queue

## Usage

### Configuration
#### Redis
The gem uses (https://github.com/kenn/redis-mutex "redis-mutex") which requires you to register the Redis server: (e.g. in `config/initializers/redis_mutex.rb` for Rails)

```ruby
RedisClassy.redis = Redis.new
```
Note that Redis Mutex uses the `redis-classy` gem internally.

#### Un Pause
Queues can be unpaused in two ways. 
The most elegant is using (https://github.com/resque/resque-scheduler, "resque-scheduler"), this work well as long as you aren't running on a platform like heroku which requires a dedicated worker to run the scheduler.

To tell the gem to use resque-scheduler you need to include resque-scheduler in your Gemfile - and also let the gem know which queue to use to schedule the unpause job (make sure this isn't a queue you've paused). Put this in an initializer.

```ruby
Resque::Plugins::RateLimitedQueue::UnPause.queue = :my_queue
```

#### Workers
Queues are paused by renaming them so a resque called 'twitter\_api' will be renamed 'twitter\_api\_paused' when it hits a rate limit. Of course this will only work if your resque workers are not also taking jobe from the 'twitter\_api\_paused' queue. So your worker commands need to look like

```ruby
bin/resque work --queues=high,low,twitter_api
```
or
```ruby
env QUEUES=high,low,twitter_api bundle exec rake jobs:work
```

NOT

```ruby
~~bin/resque work --queues=*~~
```
or
~~```ruby
env QUEUES=* bundle exec rake jobs:work
```~~

```ruby
Resque::Plugins::RateLimitedQueue::UnPause.queue = :my_queue
```


TODO: Write usage instructions here

## Contributing

1. Fork it ( https://github.com/[my-github-username]/resque_rate_limited_queue/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
