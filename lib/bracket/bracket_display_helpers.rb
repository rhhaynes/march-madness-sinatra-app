module BracketDisplayHelpers

  # == Instance Variables ==================================================== #

  # define @bracket_viewer[:regional_rounds] instance variable (hash) for passing to viewer
  def create_table_for_regional_rounds
    jagged_games_arr = pad_and_transpose( collect_games_by_round(Bracket.rounds[0..3]) )
    jagged_teams_arr = extract_teams_and_define_links(jagged_games_arr)
    @bracket_viewer = {:regional_rounds => insert_region_champions(jagged_teams_arr)}
  end

  # define @bracket_viewer[:final_rounds] instance variable (hash) for passing to viewer
  def create_table_for_final_rounds
    jagged_games_arr = pad_and_transpose( collect_games_by_round(Bracket.rounds[4..5]) )
    jagged_teams_arr = extract_teams_and_define_links(jagged_games_arr)
    @bracket_viewer[:final_rounds] = insert_bracket_champion(jagged_teams_arr)
  end

  # == Miscellaneous ========================================================= #

  # return array containing sub-arrays of games categorized by round
  def collect_games_by_round(round_names)
    round_names.collect{|round_name| @bracket.games_in_round(round_name)}
  end

  # return jagged array containing padded sub-arrays of games spanning multiple rounds
  # - prior to transpose, strategic padding is required to ensure that
  #   (1) all sub-arrays are the same size
  #   (2) the desired output is achieved
  def pad_and_transpose(rounds_arr)
    rounds_arr.collect do |games_arr|
      case games_arr.size
      when 16 then [ 4, 9,14,19].each{|idx| games_arr.insert(idx, [nil]*4)}
      when  8 then [ 2, 5, 8,11].each{|idx| games_arr.insert(idx, [nil]*6)}
      when  4 then [ 1, 3, 5, 7].each{|idx| games_arr.insert(idx, [nil]*7)}
      else games_arr.fill(nil, (games_arr.size)..(rounds_arr.first.size-1)) unless games_arr.size == rounds_arr.first.size
      end
      games_arr.flatten
    end.transpose
  end

  # return jagged array containing padded sub-arrays of teams spanning multiple rounds
  # - split each row of games into 2 rows of teams since each game has 2 teams
  def extract_teams_and_define_links(jagged_games_arr)
    jagged_games_arr.collect do |row_of_games|
      [row_of_games.collect{|game| !!game ? "<a href='/teams/#{game.teams[0].name_abbreviation.downcase}'>#{game.teams[0].region_seed} #{game.teams[0].name}</a>" : ""},
       row_of_games.collect{|game| !!game ? "<a href='/teams/#{game.teams[1].name_abbreviation.downcase}'>#{game.teams[1].region_seed} #{game.teams[1].name}</a>" : ""}]
    end
  end

  # return jagged array containing padded sub-arrays of teams spanning multiple rounds
  # - includes 1st Round, 2nd Round, Sweet 16, Elite 8, and Region Champions
  def insert_region_champions(jagged_teams_arr)
    jagged_teams_arr.collect.with_index do |row_doublet, i|
      row_doublet.collect.with_index do |row_of_teams, j|
        if [0,8,16,24].include?(i) && j == 0
          champ = @bracket.region_champions[(i/8).to_i]
          row_of_teams.push("<a href='/teams/#{champ.name_abbreviation.downcase}'>#{champ.region_seed} #{champ.name}</a>")
        else
          row_of_teams.push("")
        end
      end
    end
  end

  # return jagged array containing padded sub-arrays of teams spanning multiple rounds
  # - includes Final 4, Championship, and Bracket Champion
  def insert_bracket_champion(jagged_teams_arr)
    jagged_teams_arr.collect.with_index do |row_doublet, i|
      row_doublet.collect.with_index do |row_of_teams, j|
        if [i,j].all?{|idx| idx == 0}
          champ = @bracket.champion
          row_of_teams.push("<a href='/teams/#{champ.name_abbreviation.downcase}'>#{champ.region_seed} #{champ.name}</a>")
        else
          row_of_teams.push("")
        end
      end
    end
  end

end
