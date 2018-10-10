class CreatePrices < ActiveRecord::Migration[5.0]
  def change
    create_table :prices do |t|
      t.float :tcg_price
      t.float :ck_price
      t.references :card, foreign_key: true

      t.timestamps
    end
  end
end
