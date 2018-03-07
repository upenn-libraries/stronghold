# Stronghold

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/stronghold`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'stronghold'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install stronghold

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Testing

Note: The `aws-fog` gem does not currently implement `Fog::Mock` for Glacier.  To simulate a Glacier connection for testing, the handy-dandy Sinatra app [icemelt](https://github.com/cbeer/icemelt) is required.  Follow the deployment instructions on the repo's README and have an instance running when running the test suite, otherwises tests involving Glacier actions will fail. 

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/stronghold.
