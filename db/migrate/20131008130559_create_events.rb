class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.integer :owner
      t.integer :owner2
      
      t.timestamps
    end
  end
end
