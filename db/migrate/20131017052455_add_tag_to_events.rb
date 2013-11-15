class AddTagToEvents < ActiveRecord::Migration
  def change
    add_column :events, :tag, :string
  end
end
