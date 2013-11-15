class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.references :event
      t.string :url
      t.string :provider
      t.timestamps
    end
  end
end
