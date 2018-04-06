class CreateGames < ActiveRecord::Migration[5.1]
  def change
    create_table :games do |t|
      t.string  :round
      t.integer :bracket_id
      t.integer :team_id_winner
      t.integer :team_id_loser
    end
  end
end
