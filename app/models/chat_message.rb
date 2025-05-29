class ChatMessage < ApplicationRecord
  belongs_to :user
  validates :body, presence: true
  validates :body, length: { maximum: 10000 }
end
