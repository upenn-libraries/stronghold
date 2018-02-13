require 'stronghold/version'
require 'stronghold/configuration'

require 'aws-sdk-glacier'
require 'pry'

module Stronghold

  class << self

    def config
      @config ||= Configuration.new
    end

    def configure
      yield config
    end

    def connect_client
      if Aws.config.empty?
        Aws.config.update({
                              region: Stronghold.config.data_center,
                              credentials: Aws::Credentials.new(Stronghold.config.glacier_access_key, Stronghold.config.glacier_secret_key)
                          })
      end
      return Aws::Glacier::Client.new
    end

    def get_vault_info(vault_name)
      client = self.connect_client
      vault = client.list_vaults.vault_list.find_all{|vault| vault.vault_name == vault_name}
      return vault.empty? ? "Vault named \"#{vault_name}\" not found" : vault.inspect
    end

    def upload
    end

    def download
    end

    def delete
    end

    private



  end


end
