# README for `stronghold`

The stronghold gem provides a simple workflow for interfacing with Glacier through [fog-aws](https://github.com/fog/fog-aws).

## Supported functionality

The stronghold gem supports the following operations in Glacier:

* Synchronously transfer an archive to Glacier, returning the associated archive metadata when the job is complete.
* Initialize a vault inventory retrieval job
* Initialize an archive retrieval job
* Retrieve an archive or vault when available
* Look up status of a running job in a specified vault

The gem will create inventory or archive retrieval jobs if one is not yet in progress or recently succeeded/completed for the particular operation type and object, to cut down on proliferating jobs.  Job id(s) are returned by call functions and can be used to explicitly check the status of the running job in the specified vault.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'stronghold'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install stronghold

## Configuration

To configure for use, you can set Glacier credentials as environment variables named the following:

* ENV['GLACIER_ACCESS_KEY']
* ENV['GLACIER_SECRET_KEY']
* ENV['GLACIER_DATA_CENTER']

You can alternatively pass these credentials along as an optional hash, provided that the environment variables are *not* set, as the environment variables will override an argument hash.

#### Example for passing a hash:

```ruby
@icemelt_credentials = {:glacier_access_key => 'x', 
                        :glacier_secret_key => 'y', 
                         :data_center => 'us-east-1'}
                         
Stronghold::Client.new(@icemelt_credentials)    
```

## Usage

### Examples

```ruby
require 'stronghold'

###
#
# Initialize the client and return a vault
#
###

client = Stronghold::Client.new
vault = client.find_vault('vault_name')

###
#
# Get a vault inventory
#
###

inventory_file = 'stronghold.json'

job_ids = client.call_inventory(vault)

job_ids.each do |jid|
  job_info = client.lookup_job(vault, jid)
  case job_info[:status_code]
    when 'InProgress'
      puts "Job #{jid} is in progress"
    when 'Succeeded'
      f = File.new(inventory_file, 'w')
      f << client.get_inventory(vault, jid).to_json
      f.close
      puts "Job #{jid} succeeded.  Inventory output written to #{inventory_file}."
    else
      puts "No status code returned for job #{jid}"
  end
end

###
#
# Get an archive
#
###

archive_id = 'abc123'
file_path = '/abs/destination/for/archive.extension'

job_ids = client.call_archive(vault, archive_id)

job_ids.each do |jid|
  job_info = client.lookup_job(vault, jid)
  case job_info[:status_code]
    when 'InProgress'
      puts "Job #{jid} is in progress"
    when 'Succeeded'
      location = client.get_archive(vault, jid, file_path, 'w+')
      puts "Archive retrieved and written to #{location}"
    else
      puts "No status code returned for job #{jid}"
  end
end

```

## Additional resources

* [Amazon Glacier Developer Documentation](https://docs.aws.amazon.com/amazonglacier/latest/dev/introduction.html)
* [Fog.io](http://fog.io/)


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rspec .` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Testing

Note: The fog-aws gem does not currently implement `Fog::Mock` for Glacier.  To simulate a Glacier connection for testing, the handy-dandy Sinatra app [icemelt](https://github.com/upenn-libraries/icemelt) is required.  Follow the deployment instructions on the repo's README and have an instance running when running the test suite, otherwises tests involving Glacier actions will fail. 

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/upenn-libraries/stronghold](https://github.com/upenn-libraries/stronghold).

## License

This code is available as open source under the terms of the [Apache 2.0 License](https://opensource.org/licenses/Apache-2.0).