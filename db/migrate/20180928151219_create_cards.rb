class CreateCards < ActiveRecord::Migration[5.0]
  def change
    create_table :cards do |t|
      t.string :name
      t.integer :tcg_id
      t.boolean :is_foil
      t.references :card_set, foreign_key: true

      t.timestamps
    end
  end
end
