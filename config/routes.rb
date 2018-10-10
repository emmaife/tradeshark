Rails.application.routes.draw do
  resources :prices
  resources :cards
  resources :card_sets

  get 'search' => 'cards#search'
  get 'cards/neg' 
  get 'cards/low'
  get 'cards/low_standard'
  root to: 'card_sets#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
