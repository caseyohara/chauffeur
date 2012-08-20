require 'initializable_from_api_hash'

class FakeShirt
  include InitializableFromApiHash
end

class FakePants
  include InitializableFromApiHash
  default_api_method :get_pants
end

describe InitializableFromApiHash do
  let(:api) { stub }

  it "hits the API and creates methods for each property returned" do
    attributes = { :color => "blue", :size => "tiny" }
    shirt = FakeShirt.new(api, attributes)
    shirt.color.should == "blue"
    shirt.size.should == "tiny"
  end

  it "can default to an API call when attributes aren't passed to the constructor" do
    api.stub(:get_pants) { {:color => "indigo", :size => "enormous"} }
    pants = FakePants.new(api)
    pants.color.should == "indigo"
    pants.size.should == "enormous"
  end
end

