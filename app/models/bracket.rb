class Bracket < ActiveRecord::Base
  belongs_to :user
  has_many :games, dependent: :destroy

  include BracketModelHelpers

  def self.first_round_logic
    {"0" => {"0"=>"1", "1"=>"16"},
     "1" => {"0"=>"8", "1"=> "9"},
     "2" => {"0"=>"5", "1"=>"12"},
     "3" => {"0"=>"4", "1"=>"13"},
     "4" => {"0"=>"6", "1"=>"11"},
     "5" => {"0"=>"3", "1"=>"14"},
     "6" => {"0"=>"7", "1"=>"10"},
     "7" => {"0"=>"2", "1"=>"15"}}
  end

  def self.count_teams_in_logic(params_logic)
    params_logic.collect do |region_name, region_logic|
      region_logic.collect{|game_index, game_logic| game_logic.size}.reduce(0, :+)
    end.reduce(0, :+)
  end

  def self.current_round_from_games(n_games)
    games_per_round = self.rounds.map.with_index{|round_name, i| [(32/2**i).to_i, round_name]}.to_h
    games_per_round[n_games]
  end

  def self.current_round_from_teams(n_teams)
    teams_per_round = self.rounds.map.with_index{|round_name, i| [(64/2**i).to_i, round_name]}.to_h
    teams_per_round[n_teams]
  end

  def self.rounds
    ["1st Round", "2nd Round", "Sweet Sixteen", "Elite Eight", "Final Four", "Championship"]
  end

end
