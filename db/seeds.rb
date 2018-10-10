# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

CardSet.create([

		{name: 'Core Set 2019', tcg_id: 46, ck_id: 2350, code: '4ED' } ,
		{name: 'Unstable', tcg_id: 2092, ck_id: 3075, code: 'UST' }
	])

Card.create([

		{name: 'Testing', tcg_id: 4660, is_foil: 0, card_set_id: 1 } ,
		{name: 'Testing Foil', tcg_id: -4660, is_foil: 1, card_set_id: 1 } ,
		{name: 'Other Set', tcg_id: 5000, is_foil: 0, card_set_id: 2 } , 
		{name: 'Other Set Foil', tcg_id: -5000, is_foil: 1, card_set_id: 2 } 
	])

Price.create([
	{card_id: 1, tcg_price: 1.30, ck_price: 1.50 } ,
	{card_id: 2, tcg_price: 2.30, ck_price: 3.50 } ,
	{card_id: 3, tcg_price: 0.30, ck_price: 0.50} ,
	{card_id: 4, tcg_price: 5.30, ck_price: 5.50 } 
])