class SearchEngineResult < ApplicationRecord
  belongs_to :user
  belongs_to :keyword
  belongs_to :domain_competitor
  
end
