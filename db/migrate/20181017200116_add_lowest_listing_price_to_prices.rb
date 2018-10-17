class AddLowestListingPriceToPrices < ActiveRecord::Migration[5.0]
  def change
  	 add_column :prices, :lowest_listing_price, :float
  end
end
