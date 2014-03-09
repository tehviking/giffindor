class GifPostSerializer < ActiveModel::Serializer
  attributes :id, :url, :body
  has_one :user
end
