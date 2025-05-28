class ChatMessage < ApplicationRecord
  belongs_to :user
  validates :body, presence: true
  validates :body, length: { minimum: 20 }
end
