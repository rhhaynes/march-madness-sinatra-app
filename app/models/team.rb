class Team < ActiveRecord::Base
  has_and_belongs_to_many :games
  has_many :games_won, :class_name => "Game", :foreign_key => "team_id_winner"
  has_many :game_lost, :class_name => "Game", :foreign_key => "team_id_loser"

  def self.regions
    self.region_names.map do |region_name|
      [ region_name, self.where(:region => region_name).order(:region_seed) ]
    end.to_h
  end

  def self.region_names
    self.all.collect{|team| team.region}.uniq
  end

  def self.final_four_region_pairings
    # WARNING: values below are hardcoded to indicate how the Final Four regions combine
    self.region_names.values_at(0,3,1,2).each_slice(2).to_a
  end

  def self.region_names_final_four
    # WARNING: method depends on hardcoded values in .final_four_region_pairings
    self.final_four_region_pairings.collect{|region_pair| region_pair.join(" vs ")}
  end

  def self.region_names_championship
    # WARNING: method depends on hardcoded values in .final_four_region_pairings
    self.final_four_region_pairings.collect{|region_pair| region_pair.join("-")}.join(" vs ").lines
  end

  def self.region_names_all
    # WARNING: method depends on hardcoded values in .final_four_region_pairings
    %w[region_names region_names_final_four region_names_championship].collect do |method_name|
      Team.send(method_name)
    end.flatten
  end

  def self.region_names_in_round(round_name)
    # WARNING: method depends on hardcoded values in .final_four_region_pairings
    if    round_name == "Final Four"   then self.region_names_final_four
    elsif round_name == "Championship" then self.region_names_championship
    else  self.region_names
    end
  end
end
