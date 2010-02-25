class RenameTypeInCameraOptions < ActiveRecord::Migration
  def self.up
    rename_column :camera_options, :type, :opt_type
  end

  def self.down
    rename_column :camera_options, :opt_type, :type
  end
end
