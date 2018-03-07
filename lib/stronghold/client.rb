require_relative 'exceptions'

module Stronghold
  class Client

    attr_reader :glacier_access_key
    attr_reader :glacier_secret_key
    attr_reader :data_center

    attr_reader :scheme
    attr_reader :host
    attr_reader :port

    def initialize(opts = {}, mock = false)
      if mock
        @glacier_access_key = opts[:glacier_access_key]
        @glacier_secret_key = opts[:glacier_secret_key]
        @data_center = opts[:data_center]
        @scheme = opts[:scheme]
        @host = opts[:host]
        @port = opts[:port]
      else
        @glacier_access_key = opts[:glacier_access_key] || ENV['GLACIER_ACCESS_KEY']
        @glacier_secret_key = opts[:glacier_secret_key] || ENV['GLACIER_SECRET_KEY']
        @data_center = opts[:data_center] || ENV['GLACIER_DATA_CENTER']
        raise Exceptions::MissingGlacierCredentialsError, "Missing Glacier credentials" if [@glacier_access_key, @glacier_secret_key, @data_center].any?{ |a| a.nil? }
      end
    end

    def find_vault(vault_id)
      connection = connect_client
      vault = connection.vaults.get(vault_id)
      raise Exceptions::VaultNotFoundError, "Vault with vault id #{vault_id} not found" if vault.nil?
      return vault
    end

    def create_backup(vault_id, file_path, archive_description = nil)
      vault = find_vault(vault_id)
      backup_ids = {}
      file = File.new(file_path)
      description = archive_description.nil? ? file_path : "#{archive_description}"
      archive_id = create_archive(vault, file, description)
      backup_ids[description] = archive_id
      return backup_ids
    end

    def call_inventory(vault)
      job_ids = select_jobs(vault, {:action => 'InventoryRetrieval', :status_code => %w[InProgress Succeeded Complete]}).map(&:id)
      return job_ids unless job_ids.empty?
      job_ids = vault.jobs.create :type => Fog::AWS::Glacier::Job::INVENTORY
      return [job_ids]
    end

    def call_archive(vault, archive_id)
      job_ids = select_jobs(vault, {:action => 'ArchiveRetrieval', :status_code => %w[InProgress Succeeded Complete], :archive_id => archive_id}).map(&:id)
      return job_ids unless job_ids.empty?
      job_ids = vault.jobs.create(:type => Fog::AWS::Glacier::Job::ARCHIVE, :archive_id => archive_id)
      return [job_ids]
    end

    def get_inventory(vault, job_id)
      job = vault.jobs.get(job_id)
      return nil if job.nil?
      return job.get_output.body
    end

    def get_archive(vault, job_id, destination, mode)
      job = vault.jobs.get(job_id)
      return nil if job.nil?
      raise Exceptions::InvalidIoModeError "Invalid IO mode #{mode} supplied." if %w[r r+ w w+ a a+].include?(mode.downcase) == false
      File.open(destination, mode) do |f|
        job.get_output :io => f
      end
      return destination
    end

    def lookup_job(vault, job_id)
      job = vault.jobs.get(job_id)
      return nil if job.nil?
      return job.attributes.reject { |k,v| v.nil? }
    end

    def select_jobs(vault, options = {})
      return vault.jobs.find_all{|i| match_criteria(i, options) }
    end

    def list_jobs(vault)
      return vault.jobs.all
    end

    protected

    def match_criteria(value, criteria)
      matched = true
      criteria.each do |k, v|
        v = [v] unless v.respond_to?(:each)
        matched = false unless v.include?(value.attributes[k])
      end
      return value if matched
    end

    private

    def connect_client
      attributes = { :aws_access_key_id => self.glacier_access_key,
                     :aws_secret_access_key => self.glacier_secret_key,
                     :region => self.data_center,
                     :scheme => self.scheme,
                     :port => self.port,
                     :host => self.host
      }
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