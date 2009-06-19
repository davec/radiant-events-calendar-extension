class AddFilterToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :filter_id, :string, :limit => 25
    add_column :events, :description_html, :text
  end

  def self.down
    remove_column :events, :filter_id
    remove_column :events, :description_html
  end
end
