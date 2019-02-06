 class HardWorker
    include Sidekiq::Worker
    require 'open-uri'
    require 'nokogiri'

    def perform

        lastCard = Card.where(is_foil: false, created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).last['tcg_id']
        str = ""
        Card.where(is_foil: false, created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).each do |x|
            str = str + x['tcg_id'].to_s + ','
            if ERB::Util.url_encode(str).length >=  1500 || x['tcg_id'] == lastCard
                str = str[0...-1]
                puts str
                url = URI("http://api.tcgplayer.com/pricing/product/" +  ERB::Util.url_encode(str))
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

        CardSet.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).each do |x|
            ckSetCode = x['ck_id']
            sleep 1
            
            url = "https://www.cardkingdom.com/purchasing/mtg_singles/?filter[sort]=name&filter[search]=mtg_advanced&filter[ipp]=500&filter[rarity][0]=M&filter[rarity][1]=R&filter[category_id]=" + ckSetCode.to_s

            page = Nokogiri::HTML(open(url))

            page.css('div.itemContentWrapper').each do |result|
                unless result.css('span.sellDollarAmount')[0].nil?
                    newCardName =  result.css('span.productDetailTitle').text.strip
                    

                    foil =  result.css('div.foil').text.strip
                    price = result.css('span.sellDollarAmount')[0].text.strip + '.' + result.css('span.sellCentsAmount')[0].text.strip
                    price = price.to_f
                  
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
            sleep 1
        end

        Price.where(ck_updated: nil).update_all(ck_price: nil, spread: nil)
        Price.where("ck_updated < ?", Date.today).update_all(ck_price: nil, spread: nil)
    end
end
