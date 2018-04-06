class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string    :username
      t.string    :password_digest
      t.string    :name
      t.timestamp :created_at
      t.timestamp :updated_at
    end
  end
end
