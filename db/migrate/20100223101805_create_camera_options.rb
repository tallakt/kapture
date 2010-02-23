class CreateCameraOptions < ActiveRecord::Migration
  def self.up
    create_table :camera_options do |t|
      t.string :name
      t.string :value
      t.int :type

      t.timestamps
    end
  end

  def self.down
    drop_table :camera_options
  end
end
