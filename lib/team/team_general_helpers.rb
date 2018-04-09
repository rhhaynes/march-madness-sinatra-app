module TeamGeneralHelpers

  # == Boolean Returns (Validation) ========================================== #

  # check team validity and define @team instance variable
  def team_valid?(team_abbrev)
    !!( @team = Team.find_by(:name_abbreviation => team_abbrev.upcase) if team_abbrev == team_abbrev.downcase )
  end

  # == Miscellaneous ========================================================= #

  # return array sorted by region
  def sort_by_region(input, input_region_order)
    output_order = Team.region_names.collect{|region_name| input_region_order.index(region_name)}
    sorting_hash = Hash[ input.map.with_index{|elem, i| [i, elem]} ]
    sorting_hash.values_at(*output_order).flatten
  end

end
