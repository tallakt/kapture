class CreateWorkerFeedbacks < ActiveRecord::Migration
  def self.up
    create_table :worker_feedbacks do |t|
      t.string :status

      t.timestamps
    end
  end

  def self.down
    drop_table :worker_feedbacks
  end
end
