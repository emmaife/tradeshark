class AddCardToUserCards < ActiveRecord::Migration[5.0]
  def change
    add_reference :user_cards, :card, foreign_key: true
  end
end
