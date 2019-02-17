class Card < ApplicationRecord
  belongs_to :card_set
  has_many :watchlists

  has_many :favorites
  has_many :users, :through => :favorites
  has_one :price
end
