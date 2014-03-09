class CreateGifPosts < ActiveRecord::Migration
  def change
    create_table :gif_posts do |t|
      t.references :user, index: true
      t.string :url
      t.string :body

      t.timestamps
    end
  end
end
