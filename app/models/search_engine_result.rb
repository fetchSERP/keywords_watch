class SearchEngineResult < ApplicationRecord
  belongs_to :user
  belongs_to :keyword
end
