json.extract! backlink, :id, :user_id, :domain_id, :source_url, :target_url, :anchor_text, :nofollow, :rel_attributes, :context_text, :source_domain, :target_domain, :page_title, :meta_description, :created_at, :updated_at
json.url backlink_url(backlink, format: :json)
