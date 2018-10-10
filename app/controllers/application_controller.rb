class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
	def get_standard
		@stdArr = Array.new()
		require 'open-uri'
		content = open("https://whatsinstandard.com/api/v5/sets.json").read 

		JSON.parse(content)["sets"].each do |set|
			if set["enter_date"] <= DateTime.now && ( set["exit_date"].nil? || set["exit_date"] > DateTime.now)
				@stdArr << set["code"]
			end
		end
	end
	helper_method :get_standard

end
