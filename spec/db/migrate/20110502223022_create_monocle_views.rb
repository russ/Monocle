class CreateMonocleViews < ActiveRecord::Migration
  def self.up
    create_table :views do |t|
      t.string :viewable_type
      t.integer :viewable_id
      t.string :type
      t.date :viewed_on_start_date
      t.integer :views, :default => 0
      t.timestamps
    end

    add_index :views, [ :type, :viewable_type, :viewable_id, :views ], :name => :viewable_type_views
    add_index :views, [ :type, :viewable_type, :viewed_on_start_date, :viewable_id, :views ], :name => :viewable_type_start_date_views
    add_index :views, [ :type, :viewable_type, :viewed_on_start_date, :viewable_id ], :name => :unique_time_period_views, :unique => true
    add_index :views, [ :viewable_type, :viewable_id], :name => :index_views_on_viewable_type_and_viewable_id
  end

  def self.down
    drop_table :views
  end
end
