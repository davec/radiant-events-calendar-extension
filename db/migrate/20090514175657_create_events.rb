class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.string   :name, :null => false
      t.string   :location
      t.date     :date, :null => false
      t.datetime :start_time, :end_time
      t.string   :timezone
      t.text     :description

      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
