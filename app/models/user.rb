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
  normalizes :email_address, with: ->(e) { e.strip.downcase }
  scope :with_credit, -> { where("credit > 0") }

  def is_admin?
    role == "admin"
  end

  # Returns an initialized FetchSERP::Client using the user's personal API key
  def fetchserp_client
    @fetchserp_client ||= FetchSERP::Client.new(api_key: fetchserp_api_key)
  end

  # Fetch remaining credits from FetchSERP API (real-time)
  def fetchserp_credits
    resp = fetchserp_client.user
    resp.data.dig("user", "api_credit")
  rescue => _e
    nil
  end

  private

  def create_welcome_chat_message
    ChatMessage.create!(
      user: self,
      author: "assistant",
      body: "Hello! I'm your SEO AI Agent. I have access to your domains, keywords, backlinks, and competitors data. I can help you with keyword research, backlink analysis, and content strategies. I have access to multiple tools to help you with your SEO tasks. How can I help you today?"
    )
  end
end
