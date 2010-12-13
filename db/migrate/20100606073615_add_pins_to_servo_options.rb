class AddPinsToServoOptions < ActiveRecord::Migration
  def self.up
    add_column :servo_options, :rotation_pin, :integer
    add_column :servo_options, :tilt_pin, :integer
  end

  def self.down
    remove_column :servo_options, :tilt_pin
    remove_column :servo_options, :rotation_pin
  end
end
