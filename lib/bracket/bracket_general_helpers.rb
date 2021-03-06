module BracketGeneralHelpers

  # == Instance Variables ==================================================== #

  # define/return @user_bracket instance variable
  def user_bracket
    @user_bracket = Bracket.find_by(:user_id => current_user.id)
  end

  # == Boolean Returns (Validation) ========================================== #

  # check bracket validity and define @bracket instance variable
  def bracket_valid?(bracket_id)
    (@bracket = Bracket.find_by(:id => bracket_id)) && @bracket.complete?
  end

  # check bracket round validity and define @current_round instance variable
  def bracket_round_valid?(round_name)
    !!( @current_round = round_name if Bracket.rounds.include?(round_name) )
  end

  # == Boolean Returns (Status) ============================================== #

  # check existance status of user bracket
  def user_bracket_exists?
    !!user_bracket
  end

  # check user-ownership status of bracket
  def bracket_belongs_to_user?
    @bracket.id == user_bracket.id if user_bracket_exists?
  end

  # check regional status of specified bracket round
  def regional_round?(round_name)
    Bracket.rounds.index(round_name) < Bracket.rounds.index("Final Four")
  end

  # == Miscellaneous ========================================================= #

  # return array of games sorted by region
  def sort_games_by_region(games)
    order = games.collect{|game| game.teams.first.region}.uniq
    slice = (games.size/4).to_i
    sort_by_region(games.each_slice(slice).to_a, order)
  end

end
