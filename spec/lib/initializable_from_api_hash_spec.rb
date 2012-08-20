require 'initializable_from_api_hash'

class FakeShirt
  include InitializableFromApiHash
end

class FakePants
  include InitializableFromApiHash
  default_api_method :get_pants
end

class FakeShoes
  include InitializableFromApiHash
  skip_hash_items :style, :material
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

  it "does not automatically create method for items marked to exclude" do
    attributes = { :color => "brown", :size => "12", :style => "awesome", :material => "titanium" }
    shoes = FakeShoes.new(api, attributes)
    shoes.color.should == "brown"
    expect { shoes.style }.to raise_exception
  end
end

