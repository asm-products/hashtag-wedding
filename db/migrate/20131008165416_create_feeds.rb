class CreateFeeds < ActiveRecord::Migration
  def change
    create_table :feeds do |t|
      t.references :event
      t.string :fb_id
      t.timestamps
    end
  end
end
