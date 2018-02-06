module Stronghold
  class Configuration

    attr_accessor :glacier_access_key
    attr_accessor :glacier_secret_key
    attr_accessor :data_center
    attr_accessor :vault

    def initialize
      @glacier_access_key = ENV["GLACIER_ACCESS_KEY"]
      @glacier_secret_key = ENV["GLACIER_SECRET_KEY"]
      @data_center = ENV["GLACIER_DATA_CENTER"]
      @vault = ENV["GLACIER_VAULT"]
    end

    def inspect
      "#<#{self.class.name} #{ivars.join(', ')}>"
    end

  end

end