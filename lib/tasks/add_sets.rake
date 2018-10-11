desc 'add sets'

task :add_sets => :environment do
    require 'net/http'
    require 'uri'
    require 'date'
    require 'json'
    url = "https://mtgjson.com/json/SetList.json"
    uri = URI(url)
    response = Net::HTTP.get(uri)
    data = JSON.parse(response)
    #data.find_all {|x| x['releaseDate'] > lastSetDate}

    # get total items for offsetting
    url = URI("http://api.tcgplayer.com/catalog/categories/1/groups?")
    http = Net::HTTP.new(url.host, url.port)
    request = Net::HTTP::Get.new(url)
    request['Authorization'] = "Bearer " + ENV['API_KEY']
    response = http.request(request)
    data_b = JSON.parse(response.body)
    unless data_b['success'] == false
        totalItems= data_b['totalItems']
        num = (data_b['totalItems']/100).ceil
    end

    data.each do |set|
        ckID = nil
        url =  "https://www.cardkingdom.com/purchasing/mtg_singles?filter[sort]=price_desc"
        page = Nokogiri::HTML(open(url))
        page.css('div#editionContainer').css('div.layoutWrapper')[0].children[1].children.each do |x| 
            if  x.children.text == set['name']
                ckID = x.values[0]
            end
        end
        i = 0
        while i < num+1 do
            url = URI("http://api.tcgplayer.com/catalog/categories/1/groups?limit=100&offset=" + (i *100).to_s )
            http = Net::HTTP.new(url.host, url.port)
            request = Net::HTTP::Get.new(url)
            request['Authorization'] = "Bearer " + ENV['API_KEY']
            response = http.request(request)
            data_b = JSON.parse(response.body)
            tcgData = data_b['results'].find_all{|x| x['abbreviation'] == set['code']}
            if not (tcgData.nil? or tcgData.empty?)
                tcgID = tcgData[0]['groupId']
                CardSet.create(:name => set['name'], :code => set['code'], :ck_id=> ckID, :tcg_id => tcgID)
            end
            i+=1
        end
    end

end