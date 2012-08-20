require 'user'

describe User do
  let(:api) { stub }
  let(:user_attributes) { { 'firstName' => "Casey", 'lastName' => "O'Hara", 'key' => '1234' } }

  before do
    api.stub(:current_user) { user_attributes }
  end

  it "defaults to getting the current user from the API" do
    user = User.new(api)
    user.first_name.should == "Casey"
    user.last_name.should == "O'Hara"
  end

  context "#drivers" do
    it "creates a user instance for each person the user is following" do
      user = User.new(api)
      api.stub(:following).with({:user => user.key}).and_return {
        [{'firstName' => "Steve"}, {'firstName' => "Sally" }]
      }
      driver1, driver2  = user.drivers
      driver1.first_name.should == "Steve"
      driver2.first_name.should == "Sally"
    end
  end

  it "has a full name" do
    User.new(api).full_name.should == "Casey O'Hara"
  end

  it "has a nickname" do
    attributes = { 'url' => '/people/caseyohara' }
    User.new(api, attributes).nickname.should == "caseyohara"
  end

  it "knows when it was last seen" do
    attributes = { 'lastSongPlayTime' => "2012-08-11T01:25:49.631000" }
    User.new(api, attributes).last_seen.should == "Saturday, August 11 at 01:25am"
  end
end

