class AddSpreadToPrices < ActiveRecord::Migration[5.0]
  def change
  	 add_column :prices, :spread, :float
  end
end
