class WatchlistsController < ApplicationController
    before_action :authenticate_user!


    def index
        @watchlists = Watchlist.all
    end

    def new
        # Auto-fill the commenter's name if it has been stored in a cookie
        @watchlist = Watchlist.new(user_id: current_user_id, card_id:params[:card_id])
       # @watchlist.save
    end

  def create
    @watchlist = Watchlist.new(user_id: current_user.id, card_id: params[:card_id])
    if @watchlist.save
      flash[:notice] = "Card Added to Watchlist!"
      
      redirect_to watchlists_path
    else
      render action: "new"
    end
  end


end
