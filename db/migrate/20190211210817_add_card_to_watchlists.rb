class AddCardToWatchlists < ActiveRecord::Migration[5.0]
  def change
    add_reference :watchlists, :card, foreign_key: true
  end
end
