
require_relative 'configuration'
require_relative('exceptions')

module Stronghold
  class Client

    def config
      @config ||= Configuration.new
    end

    def configure
      yield config
    end

    attr_reader :glacier_access_key
    attr_reader :glacier_secret_key
    attr_reader :data_center

    def initialize(opts = {})
      @glacier_access_key = opts[:glacier_access_key] || config.glacier_access_key
      @glacier_secret_key = opts[:glacier_secret_key] || config.glacier_secret_key
      @data_center = opts[:data_center] || config.data_center
    end

    def find_vault(vault_id)
      connection = connect_client(self.config)
      vault = connection.vaults.get(vault_id)
      raise Exceptions::VaultNotFoundError, "Vault with vault id #{vault_id} not found" if vault.nil?
      return vault
    end

    def create_backup(vault_id, glob_expression)
      vault = find_vault(vault_id)
      backup_ids = {}
      Dir.glob(glob_expression).each do |entry|
        file = File.new(entry)
        description = entry
        archive_id = create_archive(vault, file, description)
        backup_ids[description] = archive_id
      end
      return backup_ids
    end

    def get_inventory(vault)
      job_ids = vault.jobs.find_all{|i| i.action == 'InventoryRetrieval' && i.status_code == 'InProgress' }
      return job_ids unless job_ids.empty?
      job_ids = vault.jobs.create :type => Fog::AWS::Glacier::Job::INVENTORY
      return [job_ids]
    end

    def select_jobs(vault, action, status_code)
      return vault.jobs.find_all{|i| i.action == action && i.status_code == status_code }
    end

    def list_jobs(vault)
      return vault.jobs.all
    end

    private

    def connect_client(attributes)
      attributes = { :aws_access_key_id => attributes.glacier_access_key,
                     :aws_secret_access_key => attributes.glacier_secret_key,
                     :region => attributes.data_center }

      return Fog::AWS::Glacier.new(attributes)
    end

    def create_archive(vault, body_content, description)
      body = nil
      body = "#{body_content}" if body_content.is_a?(String)
      body = body_content.read if body_content.is_a?(File)
      raise 'Invalid body type, please supply a file or strong' if body.nil?
      archive = vault.archives.create(:body => body, :description => description, :multipart_chunk_size => 1024*1024)
      archive.save
      return archive.id
    end

  end
end