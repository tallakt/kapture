class CameraOption < ActiveRecord::Base
  has_many :camera_allowed_options

  named_scope :newer_first, :order => 'updated_at DESC'


  def CameraOption.newest_updated_at_db
    o = newer_first.first
    (o && o.updated_at.to_s(:db)) || nil
  end
end
