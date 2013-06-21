class CreateFrames < ActiveRecord::Migration
  def change
    create_table :frames, :id => false do |t|
      t.uuid :id, :primary_key => true
      t.uuid :game_id
      t.uuid :cornbowler_id
      t.integer :number
      t.integer :frame_score
      t.integer :accumulated_score
      t.timestamps
    end
    add_index :frames, :game_id
    add_index :frames, :cornbowler_id
    add_index :frames, [:game_id, :cornbowler_id, :number], :unique => true
  end
end
