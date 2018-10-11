# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'resque-rate_limited_queue/version'

Gem::Specification.new do |spec|
  spec.name          = 'resque-rate_limited_queue'
  spec.version       = RateLimitedQueue::VERSION
  spec.authors       = ['Greg Dowling']
  spec.email         = ['mail@greddowling.com']
  spec.summary     = 'A Resque plugin to help manage jobs that use rate limited apis, pausing when you hit the limits and restarting later.'
  spec.description = 'A Resque plugin which allows you to create dedicated queues for jobs that use rate limited apis.
These queues will pause when one of the jobs hits a rate limit, and unpause after a suitable time period.
The rate_limited_queue can be used directly, and just requires catching the rate limit exception and pausing the
queue.'

  spec.homepage      = 'http://github.com/3dna/resque-rate-limited-queue'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'resque', '~> 1.9', '>= 1.9.10'
  spec.add_dependency 'redis-mutex', '~> 4.0', '>= 4.0.0'

  spec.add_development_dependency 'rake', '~> 10'
  spec.add_development_dependency 'rspec', '~> 2'
  spec.add_development_dependency 'simplecov', '~> 0'
  spec.add_development_dependency 'rubocop', '~> 0'
  spec.add_development_dependency 'reek', '~> 4'
  spec.add_development_dependency 'listen', '~> 3.0', '< 3.1' # Dependency of guard, 3.1 requires Ruby 2.2+
  spec.add_development_dependency 'guard', '~> 2'
  spec.add_development_dependency 'guard-rspec', '~> 4'
  spec.add_development_dependency 'guard-rubocop', '~> 1'
  spec.add_development_dependency 'gem-release', '~> 0'
end
