class Card < ApplicationRecord
  belongs_to :card_set
  has_one :price
end
