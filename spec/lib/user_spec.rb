require 'user'

describe User do
  let(:api) { stub }
  let(:user_attributes) { { 'firstName' => "Casey", 'lastName' => "O'Hara", 'key' => '1234' } }

  before do
    api.stub(:current_user) { user_attributes }
  end

  it "hits the API and creates methods for each property returned" do
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

end

