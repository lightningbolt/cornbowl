class CreateTosses < ActiveRecord::Migration
  def change
    create_table :tosses, :id => false do |t|
      t.uuid :id, :primary_key => true
      t.uuid :frame_id
      t.integer :number
      t.integer :score
      t.timestamps
    end
    add_index :tosses, [:frame_id, :number], :unique => true
  end
end
