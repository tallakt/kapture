class CreateServoOptions < ActiveRecord::Migration
  def self.up
    create_table :servo_options do |t|
      t.int :rotation_pin
      t.float :rotation_neutral
      t.float :rotation_rpm
      t.int :tilt_pin
      t.float :tilt_horizontal
      t.float :tilt_vertical

      t.timestamps
    end
  end

  def self.down
    drop_table :servo_options
  end
end
