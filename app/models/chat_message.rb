class ChatMessage < ApplicationRecord
  belongs_to :user
  validates :body, presence: true
  validates :body, length: { maximum: 20000 }
end
