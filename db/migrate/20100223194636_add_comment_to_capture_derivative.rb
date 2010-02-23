class AddCommentToCaptureDerivative < ActiveRecord::Migration
  def self.up
    add_column :capture_derivatives, :comment, :string
  end

  def self.down
    remove_column :capture_derivatives, :comment
  end
end
