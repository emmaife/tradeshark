json.extract! card, :id, :name, :tcg_id, :isFoil, :set_id_id, :created_at, :updated_at
json.url card_url(card, format: :json)
