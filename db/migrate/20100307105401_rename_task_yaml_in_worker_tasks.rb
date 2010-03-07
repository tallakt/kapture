class RenameTaskYamlInWorkerTasks < ActiveRecord::Migration
  def self.up
    add_column :worker_tasks, :task, :text
    remove_column :worker_tasks, :task_yaml
  end

  def self.down
    remove_column :worker_tasks, :task
    add_column :worker_tasks, :task_yaml, :string
  end
end
