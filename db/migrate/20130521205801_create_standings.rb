class CreateStandings < ActiveRecord::Migration
  def change
    create_table :standings, :id => false do |t|
      t.uuid :id, :primary_key => true
      t.uuid :cornbowler_id
      t.integer :wins, :default => 0
      t.integer :losses, :default => 0
      t.integer :ties, :default => 0
      t.timestamps
    end
    add_index :standings, :cornbowler_id
  end
end
