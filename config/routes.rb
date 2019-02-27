Rails.application.routes.draw do
  devise_for :users
  get 'users/new'

  resources :prices
  resources :cards
  resources :card_sets
  resources :watchlists

  post "favorites/:card_id" => "favorites#create", :as => :favorite

  get 'favorites' => 'favorites#index'
  get 'search' => 'cards#search'
  get 'cards/neg' 
  get 'cards/low'
  get 'cards/low_standard'
  get 'negative' => 'cards#negative'
  get 'low' => 'cards#low'
  get 'standard' => 'cards#standard'
  root to: 'card_sets#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
