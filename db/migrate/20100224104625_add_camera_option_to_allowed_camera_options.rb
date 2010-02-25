class AddCameraOptionToAllowedCameraOptions < ActiveRecord::Migration
  def self.up
    add_column :camera_allowed_options, :camera_option_id, :int
  end

  def self.down
    remove_column :camera_allowed_options, :camera_option_id
  end
end
