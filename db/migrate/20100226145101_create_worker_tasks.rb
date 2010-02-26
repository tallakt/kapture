class CreateWorkerTasks < ActiveRecord::Migration
  def self.up
    create_table :worker_tasks do |t|
      t.string :task_yaml

      t.timestamps
    end
  end

  def self.down
    drop_table :worker_tasks
  end
end
