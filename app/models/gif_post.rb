class GifPost < ActiveRecord::Base
  belongs_to :user
  validates :body, presence: true
  validates :url, presence: true, uniqueness: { scope: :user_id, message: "You have already posted this image. Please pick a different image and try again." }
end
