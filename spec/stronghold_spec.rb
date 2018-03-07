require 'spec_helper'

RSpec.describe Stronghold do

  before(:each) do
    @icemelt_credentials = {:glacier_access_key => 'x', :glacier_secret_key => 'y', :data_center => 'us-east-1', :scheme => 'http', :host => 'localhost', :port => '3000'}
    @mock_connection = Fog::AWS::Glacier.new({:aws_access_key_id => 'x', :aws_secret_access_key => 'y', :region => 'us-east-1', :scheme => 'http', :host => 'localhost', :port => '3000'})
  end

  it "has a version number" do
    expect(Stronghold::VERSION).not_to be nil
  end

  it "raises an error when Glacier credentials are missing" do
    expect{client = Stronghold::Client.new({:glacier_access_key => "x", :glacier_secret_key => "x", :data_center => nil})}.to raise_error(Exceptions::MissingGlacierCredentialsError)
  end

  it "raises an error when asked about a vault that does not exist in Glacier" do
    client = Stronghold::Client.new(@icemelt_credentials, mock = true)
    expect { client.find_vault('not_here') }.to raise_error(Exceptions::VaultNotFoundError)
  end

  it "returns information about a vault that exists in Glacier" do
    @mock_connection.create_vault('mock_vault')
    client = Stronghold::Client.new(@icemelt_credentials, mock = true)
    expect(client.find_vault('mock_vault')).to be_kind_of(Fog::AWS::Glacier::Vault)
    @mock_connection.delete_vault('mock_vault')
  end

  it "does not initialize a new inventory job if a matching job exists in Glacier" do
    @mock_connection.create_vault('mock_vault')
    client = Stronghold::Client.new(@icemelt_credentials, mock = true)
    vault = client.find_vault('mock_vault')
    begin
      client.call_inventory(vault)
    rescue Excon::Error::InternalServerError
      expect(client.call_inventory(vault).length).to match(1)
    end
    @mock_connection.delete_vault('mock_vault')
  end

end
