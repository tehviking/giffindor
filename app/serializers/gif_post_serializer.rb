class GifPostSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :url, :body, :username, :created_at

  def username
    object.user.username
  end
end
