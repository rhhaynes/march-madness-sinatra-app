class CreateBrackets < ActiveRecord::Migration[5.1]
  def change
    create_table :brackets do |t|
      t.string    :name
      t.integer   :user_id
      t.timestamp :created_at
      t.timestamp :updated_at
    end
  end
end
