$LOAD_PATH << './lib/'

require 'api'
require 'user'

class App < Sinatra::Base
  enable :sessions
  set :session_secret, "wazzu"

  get '/' do
    api = API.new(session)
    if api.available?
      @user = User.new(api)
      @drivers = @user.drivers
      erb :index
    else
      erb :login
    end
  end


  get '/login' do
    session.clear
    api = API.new(session)
    url = api.callback_url(request.url)
    session = api.session
    redirect url
  end


  get '/callback' do
    api = API.new(session, params)
    if api.authenticatable?
      api.complete_authentication!
      session = api.session
      redirect to '/'
    else
      redirect to '/logout'
    end
  end


  get '/logout' do
    session.clear
    redirect to('/')
  end
end

