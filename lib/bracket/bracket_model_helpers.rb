module BracketModelHelpers

  # == Boolean Returns (Status) ============================================== #

  # check completion status of bracket
  def complete?
    !!self.champion
  end

  # check full-size status of bracket (number of games == 63)
  def full?
    self.size == 63
  end

  # == Object Returns ======================================================== #

  # return bracket champion
  def champion
    self.games.find_by(:round => "Championship").winner if self.full?
  end

  # return array of regional champions
  def region_champions
    games = self.games_in_round("Elite Eight")
    games.collect{|game| game.winner} unless games.empty?
  end

  # return array of games in specified round
  def games_in_round(round_name)
    self.games.where(:round => round_name).to_a
  end

  # == Miscellaneous ========================================================= #

  # return bracket size (number of games)
  def size
    self.games.size
  end

end
