json.extract! card_set, :id, :name, :tcg_id, :ck_id, :code, :created_at, :updated_at
json.url card_set_url(card_set, format: :json)
