class CreateCaptures < ActiveRecord::Migration
  def self.up
    create_table :captures do |t|
      t.string :camera_file
      t.string :thumbnail
      t.string :fullsize

      t.timestamps
    end
  end

  def self.down
    drop_table :captures
  end
end
