class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable
  # Setup accessible (or protected) attributes for your model
  validates_presence_of :username
  has_many :gif_posts
end
