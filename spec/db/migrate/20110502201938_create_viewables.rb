class CreateViewables < ActiveRecord::Migration
  def self.up
    create_table :viewables do |t|
      t.timestamps
    end
  end

  def self.down
    drop_table :viewables
  end
end
