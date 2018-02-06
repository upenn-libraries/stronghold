RSpec.describe Stronghold do
  it "has a version number" do
    expect(Stronghold::VERSION).not_to be nil
  end

  it "has Glacier credentials" do
    pending
  end

  it "uploads an archive to Glacier" do
    pending
  end

  it "downloads an archive from Glacier" do
    pending
  end

  it "removes an archive from Glacier" do
    pending
  end

  it "returns information on a vault that exists in Glacier" do
    pending
  end

  it "returns an error message when asked about a vault that does not exist in Glacier" do
    pending
  end

end
