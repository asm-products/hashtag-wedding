class AddEventDateToEvents < ActiveRecord::Migration
  def change
    add_column :events, :event_date, :datetime
    add_column :events, :location, :string
    add_column :events, :city, :string
  end
end
