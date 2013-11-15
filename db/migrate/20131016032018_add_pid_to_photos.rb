class AddPidToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :pid, :string
  end
end
