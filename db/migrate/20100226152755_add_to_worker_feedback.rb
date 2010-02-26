class AddToWorkerFeedback < ActiveRecord::Migration
  def self.up
    add_column :worker_feedbacks, :gphoto_version, :string
    add_column :worker_feedbacks, :model_name, :string
  end

  def self.down
    remove_column :worker_feedbacks, :gphoto_version
    remove_column :worker_feedbacks, :model_name
  end
end
