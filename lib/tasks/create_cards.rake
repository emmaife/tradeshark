desc 'create cards'

task :create_cards => :environment do
	@cardHash = Hash.new
	CardSet.all.each do |x|
	    url = URI("http://api.tcgplayer.com/catalog/products?categoryId=1&getExtendedFields=true&productTypes=Cards&groupId=" + x['tcg_id'].to_s)
	    http = Net::HTTP.new(url.host, url.port)
	    request = Net::HTTP::Get.new(url)
	    request['Authorization'] = "Bearer " + ENV["SECRET_API"]
	    response = http.request(request)
	    data = JSON.parse(response.body)
	    unless data['success'] == false
	        totalItems= data['totalItems']
	        i = 0
	        num = (data['totalItems']/100).ceil
	        while i < num+1 do
	            url = URI("http://api.tcgplayer.com/catalog/products?categoryId=1&productTypes=Cards&limit=100&getExtendedFields=true&groupId=" + x['tcg_id'].to_s + '&offset=' + (i *100).to_s )
	            puts url
	            http = Net::HTTP.new(url.host, url.port)
	            request = Net::HTTP::Get.new(url)
	            request['Authorization'] = "Bearer " + ENV["SECRET_API"]
	            response = http.request(request)
	            data = JSON.parse(response.body)
	            data['results'].each do |y|
	                @cardHash[y["productId"]] = {"card_set_id" => x['id'], "name" => y["productName"], "set"=> x["code"],  "rarity"=> y['extendedData'][0]['value']}
	            end
	            i+=1
	        end
	    end
	end
	@cardHash.delete_if{|k,v|  v['rarity'] == "T" || v['rarity'] == "L" || v['rarity'] == "U" || v['rarity'] == "C" ||  v['rarity'] == "P" ||  v['rarity'] == "S"  }


	@cardHash.each  { |k,v|  Card.create(:tcg_id => k, :name => v['name'], :card_set_id => v['card_set_id']) }

	@cardHash.each  do |k,v|  
		Card.create(:tcg_id => -k, :name => v['name'], :card_set_id => v['card_set_id'])
	end
end
