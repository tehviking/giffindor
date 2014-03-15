class Favorite < ActiveRecord::Base
  belongs_to :user
  belongs_to :gif_post
  validates :gif_post, presence: true, :uniqueness => {scope: :user_id}
end
