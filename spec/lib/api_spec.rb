require 'api'

describe API do
  let(:rdio) { stub(:rdio) }
  let(:valid_session) { {:at => "token", :ats => "secret"} }


  context "#available?" do
    it "is available when the access token and access secret are present" do
      api = API.new({ :at => "some_token", :ats => "some_secret" })
      api.available?.should == true
    end

    it "is unavailable when the token is nil and the secret is present" do
      api = API.new({ :ats => "some_secret" })
      api.available?.should == false
    end

    it "is unavailable when the token is present and the secret is nil" do
      api = API.new({ :at => "some_token" })
      api.available?.should == false
    end

    it "is unavailable when both the token and secret are nil" do
      api = API.new({})
      api.available?.should == false
    end
  end


  context "#authenticatable?" do
    it "is authenticatable when it has a token, secret and verifier" do
      session = { :rt => "token", :rts => "secret" }
      params = { :oauth_verifier => "verifier" }
      API.new(session, params).authenticatable?.should == true
    end

    it "is not authenticatable when it doesn't have a token" do
      session = { :rts => "secret" }
      params = { :oauth_verifier => "verifier" }
      API.new(session, params).authenticatable?.should == false
    end

    it "is not authenticatable when it doesn't have a secret" do
      session = { :rt => "token" }
      params = { :oauth_verifier => "verifier" }
      API.new(session, params).authenticatable?.should == false
    end

    it "is not authenticatable when it doesn't have a verifier" do
      session = { :rt => "token" , :rts => "secret" }
      params = {}
      API.new(session, params).authenticatable?.should == false
    end
  end


  context "#current_user" do
    it "returns an attribute hash for the current user" do
      user_attributes = {'firstName' => "Casey", 'lastName' => "O'Hara"}
      Rdio.any_instance.stub(:call).with('currentUser', 'extras' => API::EXTRA_USER_FIELDS) { {'result' => user_attributes} }
      api = API.new(valid_session)
      api.current_user.should == user_attributes
    end
  end


  context "#following" do
    it "returns an array of attribute hashes for the user's following list" do
      following1, following2 = {'firstName' => 'Dave'}, {'firstName' => 'Donna' }
      Rdio.any_instance.stub(:call).with('userFollowing', :user => '5678', :extras => API::EXTRA_USER_FIELDS) { {'result' => [following1, following2]} }
      api = API.new(valid_session)
      api.following(user: '5678').should == [following1, following2]
    end
  end


  context "#callback_url" do
    let(:api) { API.new(valid_session) }

    before do
      Rdio.any_instance.stub(:begin_authentication)
      Rdio.any_instance.stub(:token) { ['a','b'] }
    end

    it "returns the callback authorized from Rdio" do
      callback_url = stub
      Rdio.any_instance.stub(:begin_authentication).with("http://localhost/callback") { callback_url }
      api = API.new(valid_session)
      api.callback_url("http://localhost").should == callback_url
    end

    it "sets the :rt and :rts session vars" do
      api.callback_url("http://localhost")
      api.session[:rt].should == 'a'
      api.session[:rts].should == 'b'
    end
  end


  context "complete_authentication!" do
    let(:verifier) { stub(:verifier) }
    let(:rdio) { stub(:rdio) }
    let(:api) { API.new(valid_session, { :oauth_verifier => verifier }) }
    before { Rdio.stub(:new) { rdio } }

    it "completes the authentication with Rdio" do
      rdio.should_receive(:complete_authentication).with(verifier)
      api.stub(:apply_authenticated_tokens!)
      api.complete_authentication!
    end

    it "sets the access token and access secret session vars" do
      rdio.stub(:token) { ['a','b'] }
      rdio.stub(:complete_authentication)
      api.complete_authentication!
      api.session[:at].should == 'a'
      api.session[:ats].should == 'b'
    end

    it "deletes the request token and request secret session vars" do
      rdio.stub(:complete_authentication)
      api.stub(:apply_authenticated_tokens!)
      api.session[:rt] = "not nil"
      api.session[:rts] = "also not nil"
      api.complete_authentication!
      api.session[:rt].should be_nil
      api.session[:rts].should be_nil
    end
  end
end

