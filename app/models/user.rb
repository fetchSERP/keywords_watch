class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :domains, dependent: :destroy
  has_many :keywords, dependent: :destroy
  has_many :rankings, dependent: :destroy
  has_many :backlinks, dependent: :destroy
  has_many :chat_messages, dependent: :destroy
  has_many :search_engine_results, dependent: :destroy
  has_many :competitors, dependent: :destroy
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email_address, presence: true, uniqueness: true, format: { with: VALID_EMAIL_REGEX }
  validates :password_digest, presence: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def is_admin?
    role == "admin"
  end

end
