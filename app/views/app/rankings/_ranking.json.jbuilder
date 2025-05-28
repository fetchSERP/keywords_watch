json.extract! ranking, :id, :user_id, :domain_id, :keyword_id, :rank, :search_engine, :url, :country, :created_at, :updated_at
json.url ranking_url(ranking, format: :json)
