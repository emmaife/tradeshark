class AddUserToUserCards < ActiveRecord::Migration[5.0]
  def change
    add_reference :user_cards, :user, foreign_key: true
  end
end
