class AddCardToFavorites < ActiveRecord::Migration[5.0]
  def change
    add_reference :favorites, :card, foreign_key: true
  end
end
