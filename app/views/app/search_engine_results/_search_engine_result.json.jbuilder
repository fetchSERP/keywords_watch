json.extract! search_engine_result, :id, :user_id, :keyword_id, :site_name, :url, :title, :description, :ranking, :created_at, :updated_at
json.url search_engine_result_url(search_engine_result, format: :json)
