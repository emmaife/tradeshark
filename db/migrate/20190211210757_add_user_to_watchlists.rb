class AddUserToWatchlists < ActiveRecord::Migration[5.0]
  def change
    add_reference :watchlists, :user, foreign_key: true
  end
end
