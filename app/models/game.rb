class Game < ActiveRecord::Base
  belongs_to :bracket

  has_and_belongs_to_many :teams
  belongs_to :winner, :class_name => "Team", :foreign_key => "team_id_winner"
  belongs_to :loser,  :class_name => "Team", :foreign_key => "team_id_loser"
end
