module BracketFormHelpers

  # == Instance Variables ==================================================== #

  # define @viewer instance variable (hash) for passing to viewer
  def create_viewer_logic
    # determine number of games per header (gph) in current bracket round
    if regional_round?(@current_round)
         games = sort_games_by_region( user_bracket.games_in_round(@current_round) )
    else games = user_bracket.games_in_round(@current_round)
    end
    heads = Team.region_names_in_round( @current_round)
    gph   = games.size / heads.size
    # construct @viewer[:logic] such that header => [game.id, game.id, ...]
    @viewer = {}
    @viewer[:round] = @current_round
    @viewer[:logic] = heads.collect.with_index do |header, i|
      ia = i*gph
      ib = ia+gph-1
      [ header, games[ia..ib].collect{|game| game.id} ]
    end.to_h
  end

  # == Boolean Returns (Status) ============================================== #

  # check selection status of bracket champion
  def bracket_champion_selected?(params)
    params.keys.include?(Team.region_names_championship.first)
  end

  # check preparedness status of bracket for generating a new form
  def determine_bracket_status
    if user_bracket.games.empty?
      params_logic = Team.region_names.map{|region_name| [region_name, Bracket.first_round_logic]}.to_h
      set_current_round_from_logic(params_logic)
      !!create_games_from_logic(params_logic)
    else
      bracket_round_valid?(user_bracket.games.last.round)
    end
  end

  # check definition status of @current_round instance variable
  def set_current_round_from_logic(params_logic)
    bracket_round_valid?( Bracket.current_round_from_teams(Bracket.count_teams_in_logic(params_logic)) )
  end

  # == Params Logic ========================================================== #

  # return hash containing headers (region names) mapped to associated logic
  def bundle_logic_from_params(params)
    params_logic = Team.region_names_all.map{|header| [header, params[header]]}.reject{|arr| arr.last.nil?}.to_h
    set_current_round_from_logic(params_logic)
    if    @current_round == "Final Four"   then combine_regions_for_final_four(params_logic)
    elsif @current_round == "Championship" then combine_regions_for_championship(params_logic)
    else  params_logic
    end
  end

  # return hash containing merged region names and logic for the Championship
  def combine_regions_for_championship(params_logic)
    ff_headers   = Team.region_names_final_four
    champ_header = Team.region_names_championship.first
    params_logic[champ_header] = {"0" => params_logic[ff_headers.first]["0"].merge(params_logic[ff_headers.last]["0"])}
    ff_headers.each{|header| params_logic.delete(header)}
    params_logic
  end

  # return hash containing merged region names and logic for the Final Four
  def combine_regions_for_final_four(params_logic)
    ff_headers = Team.region_names_final_four
    Team.final_four_region_pairings.each.with_index do |region_pair, i|
      params_logic[ff_headers[i]] = {"0" => params_logic[region_pair.first]["0"].merge(params_logic[region_pair.last]["0"])}
      region_pair.each{|region_name| params_logic.delete(region_name)}
    end
    params_logic
  end

  # == Game Modifications ==================================================== #

  # create new game(s) for current bracket round
  def create_games_from_logic(params_logic)
    params_logic.collect do |region_name, region_logic|
      region_logic.collect do |game_index, game_logic|
        game = user_bracket.games.build({:round => @current_round})
        if !!game.save
          if game.round == "1st Round"
            game.teams.push(
              Team.find_by(:region => region_name, :region_seed => game_logic.values.first.to_i),
              Team.find_by(:region => region_name, :region_seed => game_logic.values.last.to_i))
          else
            game.teams.push(
              Team.find_by(:id => game_logic.values.first.to_i),
              Team.find_by(:id => game_logic.values.last.to_i))
          end
        end
      end
    end.flatten
  end

  # destroy game(s) in specified and subsequent bracket rounds
  def destroy_games_to_edit
    user_bracket.games.select do |game|
      Bracket.rounds.index(game.round) >= Bracket.rounds.index(@current_round)
    end.each{|game| game.destroy}
  end

  # update Championship game with winning/losing teams
  def update_championship_from_params(params)
    champ_header = Team.region_names_championship.first
    params_logic = {champ_header => params[champ_header]}
    update_games_from_logic(params_logic)
  end

  # update game(s) with winning/losing teams
  def update_games_from_logic(params_logic)
    params_logic.collect do |region_name, region_logic|
      region_logic.collect do |game_index, game_logic|
        game_logic.collect do |game_id, team_id_winner|
          Game.update(game_id.to_i,
            :team_id_winner => team_id_winner.to_i,
            :team_id_loser  => Game.find_by(:id => game_id.to_i).
              teams.collect{|team| team.id}.reject{|team_id| team_id == team_id_winner.to_i}.first)
        end
      end
    end.flatten
  end

end
