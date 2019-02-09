

#desc "This task is called by the Heroku Schedular add-on to get CK pricing data"

#task :get_prices => :environment do
#    HardWorker.new.perform
#end



desc "retrieve API key"

task :get_key => :environment do

    require 'net/http'
    require 'uri'
    require 'date'
    require 'json'
    require 'platform-api'
    if Date.today.mday == 1 || Date.today.mday == 10 || Date.today.mday == 20

        uri = URI.parse("https://api.tcgplayer.com/token")
        request = Net::HTTP::Post.new(uri)
        request["X-Tcg-Access-Token"] = "#{ENV['ACCESS_TOKEN']}"
        request.set_form_data(
          "client_id" => "#{ENV['PUBLIC_KEY']}",
          "client_secret" => "#{ENV['PRIVATE_KEY']}",
          "grant_type" => "client_credentials",
        )

        req_options = {
          use_ssl: uri.scheme == "https",
        }

        response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
          http.request(request)
        end

        data = JSON.parse(response.body)
        key = data['access_token']

        heroku = PlatformAPI.connect_oauth(ENV['H_KEY'])
        heroku.config_var.update('tradeshark', {'API_KEY' => key})


        

      
    end

end


desc 'get listing price and hide negative cards'

task :hide_cards => :environment do
    @negCards = Card.joins(:price).where("spread < ?", 0).where(hidden: false).order('Prices.spread')
    @negCards.each do |x|
        url = URI('http://api.tcgplayer.com/v1.16.0/catalog/products/' + x['tcg_id'].abs.to_s + '/productconditions')
        http = Net::HTTP.new(url.host, url.port)
        request = Net::HTTP::Get.new(url)
        request['Authorization'] = "Bearer " + ENV["API_KEY"]
        response = http.request(request)
        data = JSON.parse(response.body)
        price =  Price.where(card_id: x['id'])[0]
        ckPrice =  price['ck_price']

        #get SKUs in lightly played condition or better
        skus = data['results'].select {|y| y['name'].match?(/Lightly Played|Near Mint/) && y['language'] == 'English' && y['isFoil'] ==  x['is_foil'] }
        url = "http://api.tcgplayer.com/v1.16.0/pricing/sku/" + skus[0]['productConditionId'].to_s + '%2C' + skus[1]['productConditionId'].to_s
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

desc "This task is called by the Heroku Schedular add-on to get pricing data"

task :get_prices => :environment do
    require 'open-uri'
    require 'nokogiri'
    lastCard = Card.where(is_foil: false).last['tcg_id']
    str = ""
    Card.where(is_foil: false).each do |x|
        str = str + x['tcg_id'].to_s + ','
        if ERB::Util.url_encode(str).length >=  1500 || x['tcg_id'] == lastCard
            str = str[0...-1]
            puts str
            url = URI("http://api.tcgplayer.com/v1.16.0/pricing/product/" +  ERB::Util.url_encode(str))
            http = Net::HTTP.new(url.host, url.port)
            request = Net::HTTP::Get.new(url)
            request['Authorization'] = "Bearer " + ENV["API_KEY"]
            response = http.request(request)
            data = JSON.parse(response.body)

            data['results'].each do |y|
                if y["subTypeName"] == "Normal"
                    c = Card.find_by(tcg_id: y['productId'])
                    price = Price.where(card_id: c.id).first_or_initialize
                    price.tcg_price =  y["midPrice"]
                    price.save
                elsif y["subTypeName"] == "Foil"
                    c = Card.find_by(tcg_id: -(y['productId']))
                    price = Price.where(card_id: c.id).first_or_initialize
                    price.tcg_price =  y["midPrice"]
                    price.save
                end
            end
            str = ""
            sleep 0.5
        end
    end

    CardSet.all.each do |x|
        ckSetCode = x['ck_id']
        sleep 1
         #masterpiece sets labeled as special on card kingdom
        if ckSetCode == 2984 || ckSetCode == 3044
            url = "https://www.cardkingdom.com/purchasing/mtg_singles/?filter[sort]=name&filter[search]=mtg_advanced&filter[ipp]=500&filter[rarity][5]=S&filter[rarity][0]=M&filter[rarity][1]=R&filter[category_id]=" + ckSetCode.to_s
        else
            url = "https://www.cardkingdom.com/purchasing/mtg_singles/?filter[sort]=name&filter[search]=mtg_advanced&filter[ipp]=500&filter[rarity][0]=M&filter[rarity][1]=R&filter[category_id]=" + ckSetCode.to_s
        end

        page = Nokogiri::HTML(open(url))

        page.css('div.itemContentWrapper').each do |result|
            unless result.css('span.sellDollarAmount')[0].nil?
                newCardName =  result.css('span.productDetailTitle').text.strip
                 #M19 set -- remove additional text from ck name
                if ckSetCode == 3097 
                    newCardName .gsub!(" (Planeswalker Deck)", "")
                end

                foil =  result.css('div.foil').text.strip
                price = result.css('span.sellDollarAmount')[0].text.strip + '.' + result.css('span.sellCentsAmount')[0].text.strip
                price = price.to_f
                 #bc masterpiece sets are all foil and name on card kingdom include original set in parentheses
                if ckSetCode == 2984 || ckSetCode == 3044
                    newCardName = newCardName.split(" (")[0]

                    f = Card.find_by(name: newCardName, is_foil: true, card_set_id: x['id'])

                    unless f.nil?
                        mpCardPrice = Price.find_by(card_id: f['id'])
                        mpCardPrice.update_attribute(:ck_updated, Time.now) 
                        mpCardPrice.update_attribute(:ck_price, price ) 
                        unless mpCardPrice["tcg_price"].nil?
                            spread =  ((1 - (price/mpCardPrice["tcg_price"]))*100)
                            mpCardPrice.update_attribute(:spread, spread  ) 
                        end
                    end
                else
                    if foil != "FOIL"
                        m = Card.find_by(name: newCardName, is_foil: false, card_set_id: x['id'])

                        unless m.nil?
                            cardPrice = Price.find_by(card_id: m['id'])
                            cardPrice.update_attribute(:ck_updated, Time.now)
                            cardPrice.update_attribute(:ck_price, price )
                            unless cardPrice["tcg_price"].nil?
                                spread =  ((1 - (price/cardPrice["tcg_price"]))*100)
                                cardPrice.update_attribute(:spread, spread  ) 
                             end
                        end

                    elsif foil == "FOIL"
                        f = Card.find_by(name: newCardName, is_foil: true, card_set_id: x['id'])

                        unless f.nil?
                            foilCardPrice = Price.find_by(card_id: f['id'])
                            foilCardPrice.update_attribute(:ck_updated, Time.now) 
                            foilCardPrice.update_attribute(:ck_price, price ) 
                            unless foilCardPrice["tcg_price"].nil?
                                spread =  ((1 - (price/foilCardPrice["tcg_price"]))*100)
                                foilCardPrice.update_attribute(:spread, spread  ) 
                            end
                        end
                    end
                end
            end
        end
        sleep 1
    end
    
    #makes sure that a card that is no longer listed on card kingdom has it's price updated to nil
    Price.where(ck_updated: nil).update_all(ck_price: nil, spread: nil)
    Price.where("ck_updated < ?", Date.today).update_all(ck_price: nil, spread: nil)
    Rake::Task["hide_cards"].invoke

end


desc "Task called by heroku to add new sets and cards"

task :add_new_sets_and_cards => :environment do
    require 'net/http'
    require 'uri'
    require 'open-uri'
    require 'date'
    require 'json'
    require 'nokogiri'
    url = "https://mtgjson.com/json/Standard.json"
    uri = URI(url)
    response = Net::HTTP.get(uri)
    data = JSON.parse(response)
    data.each do |k,v|
        CardSet.where(code: k).first_or_create do |c|
            c.name = v["name"]
            c.tcg_id = v["tcgplayerGroupId"]
            ckID = nil
            url =  "https://www.cardkingdom.com/purchasing/mtg_singles?filter[sort]=price_desc"
            page = Nokogiri::HTML(open(url))
            page.css('div#editionContainer').css('div.layoutWrapper')[0].children[1].children.each do |x| 
                if  x.children.text == v["name"]
                    ckID = x.values[0]
                    c.ck_id = ckID
                end
            end
        end
    end

    # Add cards for new sets
    Card.where(updated_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).length
    @cardHash = Hash.new
    CardSet.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).each do |x|
        url = URI("http://api.tcgplayer.com/v1.16.0/catalog/products?categoryId=1&getExtendedFields=true&productTypes=Cards&groupId=" + x['tcg_id'].to_s)
        http = Net::HTTP.new(url.host, url.port)
        request = Net::HTTP::Get.new(url)
        request['Authorization'] = "Bearer " + ENV["API_KEY"]
        response = http.request(request)
        data = JSON.parse(response.body)
        unless data['success'] == false
            totalItems= data['totalItems']
            i = 0
            num = (data['totalItems']/100).ceil
            while i < num+1 do
                url = URI("http://api.tcgplayer.com/v1.16.0/catalog/products?categoryId=1&productTypes=Cards&limit=100&getExtendedFields=true&groupId=" + x['tcg_id'].to_s + '&offset=' + (i *100).to_s )
                puts url
                http = Net::HTTP.new(url.host, url.port)
                request = Net::HTTP::Get.new(url)
                request['Authorization'] = "Bearer " + ENV["API_KEY"]
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

    @cardHash.each  do |k,v|  
        Card.create(:tcg_id => k, :name => v['name'], :card_set_id => v['card_set_id'], :is_foil => false, :hidden => false)
        Card.create(:tcg_id => -k, :name => v['name'], :card_set_id => v['card_set_id'], :is_foil => true, :hidden => false)
    end

    #get prices for new cards
     HardWorker.new.perform
    
end
