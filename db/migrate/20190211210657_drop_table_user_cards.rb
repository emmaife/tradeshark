class DropTableUserCards < ActiveRecord::Migration[5.0]
 

  def up
    drop_table :user_cards
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
