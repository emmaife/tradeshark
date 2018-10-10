

desc "This task is called by the Heroku Schedular add-on to get CK pricing data"

task :get_prices => :environment do
    HardWorker.new.perform
end

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
        heroku.config_var.update('trade-shark', {'API_KEY' => key})


        

      
    end

end