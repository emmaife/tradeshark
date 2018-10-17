desc 'get listing price and hide negative cards'

task :hide_cards => :environment do
	@negCards = Card.joins(:price).where("spread < ?", 0).where(hidden: false).order('Prices.spread')
	@negCards.each do |x|
		url = URI('http://api.tcgplayer.com/v1.14.0/catalog/products/' + x['tcg_id'].abs.to_s + '/productconditions')
		http = Net::HTTP.new(url.host, url.port)
		request = Net::HTTP::Get.new(url)
		request['Authorization'] = "Bearer " + ENV["API_KEY"]
		response = http.request(request)
		data = JSON.parse(response.body)
		price =  Price.where(card_id: x['id'])[0]
		ckPrice =  price['ck_price']

		#get SKUs in lightly played condition or better
		skus = data['results'].select {|y| y['name'].match?(/Lightly Played|Near Mint/) && y['language'] == 'English' && y['isFoil'] ==  x['is_foil'] }
		url = "http://api.tcgplayer.com/pricing/sku/" + skus[0]['productConditionId'].to_s + '%2C' + skus[1]['productConditionId'].to_s
		url = URI(url)
		http = Net::HTTP.new(url.host, url.port)
		request = Net::HTTP::Get.new(url)
		request['Authorization'] = "Bearer " + ENV["API_KEY"]
		response = http.request(request)
		data2 = JSON.parse(response.body)
		nearMint = data2['results'][0]['lowestListingPrice']
		lightlyPlayed = data2['results'][1]['lowestListingPrice']

		priceArr = []
		if not nearMint.nil? 
		priceArr << nearMint
		end
		if not lightlyPlayed.nil? 
		priceArr << lightlyPlayed
		end

		if priceArr.empty? || (priceArr.min >= ckPrice)
			Card.find(x.id).update_column(:hidden, true)

		elsif priceArr.min < ckPrice 
			Card.find(x.id).update_column(:hidden, false)
			
		end
		if not priceArr.empty? 
			price.update(lowest_listing_price: priceArr.min )
		end


	end
end