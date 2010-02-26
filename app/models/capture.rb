class Capture < ActiveRecord::Base
  has_many :capture_derivatives
  named_scope :with_previews, :conditions => ['thumbnail IS NOT NULL']

  def Capture.last_with_preview
    Capture.with_previews.last
  end
end
