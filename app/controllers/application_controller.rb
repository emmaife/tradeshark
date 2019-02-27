class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
	def get_standard
		@standrd_arr = Array.new()
		require 'open-uri'
		content = open("https://whatsinstandard.com/api/v5/sets.json").read 

		JSON.parse(content)["sets"].each do |set|
			if set["enter_date"] <= DateTime.now && ( set["exit_date"].nil? || set["exit_date"] > DateTime.now)
				@standrd_arr << set["code"]
			end
		end
	end
	helper_method :get_standard


	def best_pos_spread
		@bestPosSpread = Card.joins(:price).joins(:card_set).where("spread >= ?", 0).where("spread < ?", 21).where('code IN (?)', @standrd_arr).order('Prices.spread')[0..4]
	end

	def neg_spread
		@negativeCards = Card.joins(:price).where("spread < ?", 0).where(hidden: false).order('Prices.spread')[0..4]
	end


end
