class CreateMatchups < ActiveRecord::Migration
  def change
    create_table :matchups, :id => false do |t|
      t.uuid :id, :primary_key => true
      t.uuid :game_id
      t.uuid :cornbowler_id
      t.integer :order_rank
      t.integer :final_score
      t.timestamps
    end
    add_index :matchups, [:game_id, :cornbowler_id], :unique => true
    add_index :matchups, [:game_id, :order_rank], :unique => true
    add_index :matchups, :cornbowler_id
  end
end
