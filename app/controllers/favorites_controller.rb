class FavoritesController < ApplicationController

    def index
        @favorites = current_user.favorites
    end

    def create
        if  current_user.favorites.where(card_id: params[:card_id]).empty?
            current_user.favorites.create(:card_id => params[:card_id])
        else
            @favorite = Favorite.find_by(card_id: params[:card_id])
             @favorite.destroy
        end
        render :layout => false

        respond_to do |format|
            format.js
        end
    end

    def destroy
        if current_user.favorites.where(card_id: params[:card_id]).exists?
            @favorite = Favorite.find_by(card_id: params[:card_id])
            @favorite.destroy
        end
       
    end
end
