class CreateCardSets < ActiveRecord::Migration[5.0]
  def change
    create_table :card_sets do |t|
      t.string :name
      t.integer :tcg_id
      t.integer :ck_id
      t.string :code

      t.timestamps
    end
  end
end
