class AddCkUpdatedToPrices < ActiveRecord::Migration[5.0]
  def change
  	add_column :prices, :ck_updated, :datetime
  end
end
