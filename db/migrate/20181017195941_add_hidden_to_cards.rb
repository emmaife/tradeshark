class AddHiddenToCards < ActiveRecord::Migration[5.0]
  def change
  	 add_column :cards, :hidden, :boolean
  end
end
