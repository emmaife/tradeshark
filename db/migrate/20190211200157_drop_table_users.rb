class DropTableUsers < ActiveRecord::Migration[5.0]
 

  def up
    drop_table :users
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
