class TeamController < ApplicationController

  # show team index page (list of all teams in tournament)
  get "/teams" do
    if logged_in?
      erb :"team/index.html"
    else
      redirect "/"
    end
  end

  # show team page (individual team and stats)
  get "/teams/:abbrev" do
    if logged_in?
      if team_valid?(params["abbrev"])
        erb :"team/show.html"
      else
        redirect "/teams"
      end
    else
      redirect "/"
    end
  end

end
