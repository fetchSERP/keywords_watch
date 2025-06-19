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
  after_commit :create_welcome_chat_message, on: :create
  before_create :set_default_credit
  normalizes :email_address, with: ->(e) { e.strip.downcase }
  scope :with_credit, -> { where("credit > 0") }

  def is_admin?
    role == "admin"
  end

  private

  def create_welcome_chat_message
    ChatMessage.create!(
      user: self,
      author: "assistant",
      body: "Hello! I'm your SEO AI Agent. I have access to your domains, keywords, backlinks, and competitors data. I can help you with keyword research, backlink analysis, and content strategies. I have access to multiple tools to help you with your SEO tasks. How can I help you today?"
    )
  end

  def set_default_credit
    self.credit = 250
  end

end
