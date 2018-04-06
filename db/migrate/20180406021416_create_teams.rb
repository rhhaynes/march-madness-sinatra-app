class CreateTeams < ActiveRecord::Migration[5.1]
  def change
    create_table :teams do |t|
      t.string  :name
      t.string  :name_abbreviation
      t.string  :nickname
      t.string  :season_record
      t.string  :region
      t.integer :region_seed
    end
  end
end
