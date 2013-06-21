class CreateGames < ActiveRecord::Migration
  def change
    create_table :games, :id => false do |t|
      t.uuid :id, :primary_key => true
      t.string :name
      t.timestamp :start_time
      t.timestamp :end_time
      t.timestamps
    end
  end
end
