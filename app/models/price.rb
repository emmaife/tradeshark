class Price < ApplicationRecord
  belongs_to :card
  has_paper_trail only: [:tcg_price, :ck_price, :spread]
end
