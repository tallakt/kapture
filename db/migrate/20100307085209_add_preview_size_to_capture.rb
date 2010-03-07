class AddPreviewSizeToCapture < ActiveRecord::Migration
  def self.up
    add_column :captures, :preview_w, :int
    add_column :captures, :preview_h, :int
  end

  def self.down
    remove_column :captures, :preview_w
    remove_column :captures, :preview_h
  end
end
