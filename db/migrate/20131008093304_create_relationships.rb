class CreateRelationships < ActiveRecord::Migration
  def change
    create_table :relationships do |t|
      t.references :user
      t.integer :so_user_id
      t.timestamps
    end
  end
end
