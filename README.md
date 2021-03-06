# Resque Rate Limited Queue

A Resque plugin which makes handling jobs that use rate limited apis easier

If you have a series of jobs in a queue, this gem will pause the queue when one of the jobs hits a rate limit, and re-start the queue when the rate limit has expired.

You need to write a little code that catches the rate limit signal.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'resque-rate_limited_queue'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install resque-rate_limited_queue

## Usage

### Configuration
#### Redis
The gem uses [redis-mutex](https://github.com/kenn/redis-mutex ) which requires you to register the Redis server: (e.g. in `config/initializers/redis_mutex.rb` for Rails)

```ruby
RedisClassy.redis = Redis.new
```
Note that Redis Mutex uses the `redis-classy` gem internally.

#### Un Pause
Queues can be unpaused in two ways.

The most elegant is using [resque-scheduler](https://github.com/resque/resque-scheduler), this works well as long as you aren't running on a platform like heroku which requires a dedicated worker to run the resque-scheduler.

To tell the gem to use `resque-scheduler` you need to include it in your Gemfile - and also let the gem know which queue to use to schedule the unpause job (make sure this isn't a queue that could get paused). Put this in an initializer.

```ruby
Resque::Plugins::RateLimitedQueue::UnPause.queue = :my_queue
```

Please see the section below on how to unpause on heroku as an alternative. If you don't install `resque-scheduler` AND configure the queue, then the gem will not schedule unpause jobs this way.

#### Workers
Queues are paused by renaming them, so a resque queue called 'twitter\_api' will be renamed 'twitter\_api\_paused' when it hits a rate limit. Of course this will only work if your resque workers are not also taking jobs from the 'twitter\_api\_paused' queue. So your worker commands need to look like:

Either
```ruby
bin/resque work --queues=high,low,twitter_api
```
or
```ruby
env QUEUES=high,low,twitter_api bundle exec rake jobs:work
```

NOT
```ruby
bin/resque work --queues=*
```
or NOT
```ruby
env QUEUES=* bundle exec rake jobs:work
```

#### Unpausing on heroku
The built in schedler on heroku doesn't support dynamic scheduling from an API, so unless you want to provision an extra worker to run resque-scheduler - the best option is just to unpause all your queues on a regular basis. If they aren't paused this is a harmless no-op. If not enough time has elapsed the jobs will just hit the rate_limit and get paused again. We've found that a hourly 'rake unpause' job seems to work well. The rake task would need to call:

```ruby
Resque::Plugins::RateLimitedQueue.TwitterQueue.un_pause
Resque::Plugins::RateLimitedQueue.AngellistQueue.un_pause
MyQueue.un_pause
MyJob.un_pause
```

### A single class of pausable job using a new api
If you only have one class of job you want to queue using the api, then you can use the PauseQueue module directly

```ruby
class MyApiJob
  extend Resque::Plugins::RateLimitedQueue
  @queue = :my_api
  WAIT_TIME = 60*60

  def self.perform(*params)
    do_api_stuff
  rescue MyApiRateLimit
    pause_until(Time.now + WAIT_TIME, name)
    rate_limited_requeue(self, *params)
  end

  def self.enqueue(*params)
    rate_limited_enqueue(self, *params)
  end
end
````

### Multiple classes of pausable job using a new api
If you have more than one class of job you want to queue to the api, then you need to add another Queue class. This isn't hard

```ruby
class MyApiQueue < Resque::Plugins::RateLimitedQueue::BaseApiQueue
  @queue = :my_api
  WAIT_TIME = 60*60

  def self.perform(klass, *params)
    super
  rescue MyApiRateLimit
    pause_until(Time.now + WAIT_TIME, name)
    rate_limited_requeue(self, klass, *params)
  end
end
````
If you do this - please contribute - and I'll add to the gem.

## Development Documentation
All the functions are class methods

```ruby
rate_limited_enqueue(klass, *params)
rate_limited_requeue(klass, *params)
````
Queue the job specified to the resque queue specified by `@queue`. `rate_limited_requeue` is intended for use when you need the job to be pushed back to the queue; there are two reasons to split this from `rate_limited_enqueue`. Firstly it makes testing with stubs easier - secondly there is a boundary condition when you need to requeue the last job in the queue.

```ruby
pause
````
Pauses the queue specified by `@queue`, if it is not already paused.
In most cases you should call `pause_until` to pause a queue when you hit a rate limit.

```ruby
un_pause
````
Un-pauses the queue specified by `@queue`, if it is paused.

```ruby
pause_until(timestamp)
````
Pauses the queue (specified by `@queue`) and then queues a job to unpause the queue specified by `@queue`, using resque-scheduler to the queue specified by `Resque::Plugins::RateLimitedQueue::UnPause.queue` at the timestamp specified.
If `resque-schedule` is not included, or `UnPause.queue` isn't specified this will just pause the queue.

This is the prefered function to call when you hit a rate limit, since it with work regardless of the unpause method used by the application.

```ruby
paused?
````
This returns true or false to indicate wheher the queue is paused. Be aware that the queue state could change get after the call returns, but before your code executes. Use `with_lock` if you need to avoid this.

```ruby
paused_queue_name
````
Returns the name of the queue when it is paused.

```ruby
with_lock(&block)
````
Takes ownership of the PauseQueue semaphor before executing the block passed. Useful if you need to test the state of the queue and take some action without the state changing.

```ruby
find_class(klass)
````
Takes the parameter passed, and if it's a string class name, tries to turn it into a class.


## Contributing

1. Fork it ( https://github.com/[my-github-username]/resque_rate_limited_queue/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request


## Version history

0.0.x Mostly pre-release versions

1.0.0 First release version. Breaking change - renamed  `pause_for` to be `pause_until` to better reflect function



## Final thoughts
Thanks to [Dominic](https://github.com/dominicsayers) for idea of renaming the redis key - and the sample code that does this.

This is my first gem - so please forgive any errors - and feedback very welcome
