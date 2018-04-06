class ApplicationController < Sinatra::Base
  include ApplicationControllerHelpers

  configure do
    enable :sessions
    set :session_secret, "password_security"
    set :views, "app/views"
  end

end
