class AddCaptureToCaptureDerivative < ActiveRecord::Migration
  def self.up
    add_column :capture_derivatives, :capture_id, :int
  end

  def self.down
    remove_column :capture_derivatives, :capture_id
  end
end
