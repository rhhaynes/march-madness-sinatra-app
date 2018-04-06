class UserController < ApplicationController

  # show signup/login page
  get "/" do
    if logged_in?
      redirect "/account"
    else
      erb :"user/index.html"
    end
  end

  # create new user, save to session, and redirect to account page
  post "/signup" do
    user = User.new(:username => params["username"], :password => params["password"], :name => params["name"])
    if !!user.save
      session[:user_id] = user.id
      redirect "/account"
    else
      redirect "/"
    end
  end

  # find user, save to session, and redirect to account page
  post "/login" do
    user = User.find_by(:username => params["username"])
    if !!user && !!user.authenticate(params["password"])
      session[:user_id] = user.id
      redirect "/account"
    else
      redirect "/"
    end
  end

  # show account page
  get "/account" do
    if logged_in?
      erb :"user/show.html"
    else
      redirect "/"
    end
  end

  # create new bracket and redirect to bracket form page
  post "/account" do
    if logged_in?
      params["bracket_name"] = "#{current_user.username}_0001" if params["bracket_name"].strip.empty?
      bracket = current_user.build_bracket(:name => params["bracket_name"])
      if !!bracket.save
        redirect "/brackets/new"
      else
        redirect "/account"
      end
    else
      redirect "/"
    end
  end

  # clear session and redirect to signup/login page
  get "/logout" do
    session.clear if logged_in?
    redirect "/"
  end

end
