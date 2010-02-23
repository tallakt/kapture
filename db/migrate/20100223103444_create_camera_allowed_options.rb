class CreateCameraAllowedOptions < ActiveRecord::Migration
  def self.up
    create_table :camera_allowed_options do |t|
      t.string :value
      t.int :camera_option_id

      t.timestamps
    end
  end

  def self.down
    drop_table :camera_allowed_options
  end
end
