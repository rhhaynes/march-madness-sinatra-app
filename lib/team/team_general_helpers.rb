module TeamGeneralHelpers

  # == Boolean Returns (Validation) ========================================== #

  # check team validity and define @team instance variable
  def team_valid?(team_abbrev)
    !!( @team = Team.find_by(:name_abbreviation => team_abbrev.upcase) if team_abbrev == team_abbrev.downcase )
  end

end
