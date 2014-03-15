class FavoriteSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :gif_post_id
end
