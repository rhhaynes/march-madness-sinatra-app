class BracketController < ApplicationController
  include BracketControllerHelpers

  # show bracket index page
  get "/brackets" do
    if logged_in?
      erb :"bracket/index.html"
    else
      redirect "/"
    end
  end

  # show bracket form page
  get "/brackets/new" do
    if logged_in?
      if !user_bracket_exists?
        redirect "/account"
      elsif user_bracket.complete?
        redirect "/brackets/#{user_bracket.id}"
      else
        create_new_form_logic
        erb :"bracket/new.html"
      end
    else
      redirect "/"
    end
  end

  # process results of bracket form page
  post "/brackets" do
    if logged_in?
      if bracket_champion_selected?(params)
        update_championship_from_params(params)
        redirect "/brackets/#{user_bracket.id}"
      else
        process_new_form_logic(params)
        erb :"bracket/new.html"
      end
    else
      redirect "/"
    end
  end

  # show bracket page
  get "/brackets/:id" do
    if logged_in?
      if bracket_valid?(params["id"])
        create_bracket_display
        erb :"bracket/show.html"
      else
        redirect "/brackets"
      end
    else
      redirect "/"
    end
  end

  # show edit-bracket form page
  get "/brackets/:id/edit" do
    if logged_in?
      if bracket_valid?(params["id"]) && bracket_belongs_to_user?
        if bracket_round_valid?(params["edit"])
          create_edit_form_logic
          erb :"bracket/edit.html"
        else
          redirect "/brackets/#{user_bracket.id}"
        end
      else
        redirect "/account"
      end
    else
      redirect "/"
    end
  end

  # process results of edit-bracket form page
  patch "/brackets/:id" do
    if logged_in?
      if bracket_champion_selected?(params)
        update_championship_from_params(params)
        redirect "/brackets/#{user_bracket.id}"
      else
        process_edit_form_logic(params)
        erb :"bracket/new.html"
      end
    else
      redirect "/"
    end
  end

  # delete bracket and associated games and redirect to account page
  delete "/brackets/:id/delete" do
    if logged_in?
      if bracket_valid?(params["id"]) && bracket_belongs_to_user?
        @bracket.destroy
      end
      redirect "/account"
    else
      redirect "/"
    end
  end

end
