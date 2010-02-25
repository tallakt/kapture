class AddTypeToCameraOptions < ActiveRecord::Migration
  def self.up
    add_column :camera_options, :type, :int
  end

  def self.down
    remove_column :camera_options, :type
  end
end
