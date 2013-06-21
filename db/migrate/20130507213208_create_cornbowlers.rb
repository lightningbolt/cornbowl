class CreateCornbowlers < ActiveRecord::Migration
  def change
    create_table :cornbowlers, :id => false do |t|
      t.uuid :id, :primary_key => true
      t.string :name
      t.timestamps
    end
  end
end
