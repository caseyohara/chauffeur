require 'rdio'
require 'uri'

if File.exists? File.dirname(__FILE__) + "/rdio_api_keys.rb"
  require File.dirname(__FILE__) + "/rdio_api_keys.rb"
end

class API
  RDIO_CONSUMER_KEY = ENV['RDIO_CONSUMER_KEY']
  RDIO_CONSUMER_SECRET = ENV['RDIO_CONSUMER_SECRET']
  EXTRA_USER_FIELDS = 'lastSongPlayed'

  attr_accessor :session, :params

  def initialize(session, params=nil)
    @session = session
    @params = params
  end

  def available?
    if access_token and access_token_secret
      true
    else
      false
    end
  end

  def authenticatable?
    if request_token and request_token_secret and verifier
      true
    else
      false
    end
  end

  def access_token
    session[:at]
  end

  def access_token_secret
    session[:ats]
  end

  def request_token
    session[:rt]
  end

  def request_token_secret
    session[:rts]
  end

  def verifier
    params[:oauth_verifier]
  end

  def rdio
    @rdio ||= Rdio.new([RDIO_CONSUMER_KEY, RDIO_CONSUMER_SECRET], [access_token, access_token_secret])
  end

  def current_user
    rdio.call('currentUser', 'extras' => EXTRA_USER_FIELDS)['result']
  end

  def following(params)
    rdio.call('userFollowing', params)['result']
  end

  def callback_url(url)
    @rdio = Rdio.new([RDIO_CONSUMER_KEY, RDIO_CONSUMER_SECRET])
    url = authenticated_url(url)
    apply_request_tokens!
    return url
  end

  def authenticated_url(url)
    url = URI.join(url, '/callback').to_s
    @rdio.begin_authentication(url)
  end

  def apply_request_tokens!
    self.session[:rt] = @rdio.token[0]
    self.session[:rts] = @rdio.token[1]
  end

  def complete_authentication!
    @rdio = Rdio.new([RDIO_CONSUMER_KEY, RDIO_CONSUMER_SECRET], [request_token, request_token_secret])
    @rdio.complete_authentication(verifier)
    apply_authenticated_tokens!
    purge_request_tokens!
  end

  def apply_authenticated_tokens!
    self.session[:at] = @rdio.token[0]
    self.session[:ats] = @rdio.token[1]
  end

  def purge_request_tokens!
    self.session.delete(:rt)
    self.session.delete(:rts)
  end
end

