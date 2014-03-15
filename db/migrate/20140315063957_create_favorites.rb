class CreateFavorites < ActiveRecord::Migration
  def change
    create_table :favorites do |t|
      t.references :user, index: true
      t.references :gif_post, index: true

      t.timestamps
    end
  end
end
