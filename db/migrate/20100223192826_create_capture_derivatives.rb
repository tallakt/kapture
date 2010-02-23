class CreateCaptureDerivatives < ActiveRecord::Migration
  def self.up
    create_table :capture_derivatives do |t|
      t.int :capture_id
      t.string :filename

      t.timestamps
    end
  end

  def self.down
    drop_table :capture_derivatives
  end
end
