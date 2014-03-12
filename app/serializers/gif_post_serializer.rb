class GifPostSerializer < ActiveModel::Serializer
  attributes :id, :url, :body, :username

  def username
    object.user.username
  end
end
